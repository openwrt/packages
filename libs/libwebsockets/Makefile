#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libwebsockets
PKG_VERSION:=1.7.5
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/warmcat/libwebsockets.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_SOURCE_SUBDIR)

PKG_LICENSE:=LGPL-2.1+exception
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/$(PKG_NAME)/Default
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=libwebsockets
	DEPENDS:=+zlib
	URL:=https://libwebsockets.org
	MAINTAINER:=Karl Palsson <karlp@remake.is>
endef

define Package/$(PKG_NAME)-nossl
	$(call Package/$(PKG_NAME)/Default)
	TITLE += (no SSL/TLS)
	VARIANT:=nossl
endef

define Package/$(PKG_NAME)-openssl
	$(call Package/$(PKG_NAME)/Default)
	TITLE += (OpenSSL)
	DEPENDS += +libopenssl
	VARIANT:=openssl
endef

define Package/$(PKG_NAME)-cyassl
	$(call Package/$(PKG_NAME)/Default)
	TITLE += (CyaSSL)
	DEPENDS += +libcyassl
	VARIANT:=cyassl
endef

define Package/$(PKG_NAME)-full
	$(call Package/$(PKG_NAME)/Default)
	TITLE += (OpenSSL + extras)
	DEPENDS += +libopenssl +PACKAGE_$(PKG_NAME)-full_libuv:libuv
	PROVIDES:=$(PKG_NAME)-openssl
	VARIANT:=full
endef

define Package/$(PKG_NAME)-full/config
	config PACKAGE_$(PKG_NAME)-$(VARIANT)_libuv
		bool "libuv support"
		depends on PACKAGE_$(PKG_NAME)-$(VARIANT)
		default y

	config PACKAGE_$(PKG_NAME)-$(VARIANT)_CGI
		bool "CGI support"
		depends on PACKAGE_$(PKG_NAME)-$(VARIANT)
		default y

endef

ifeq ($(BUILD_VARIANT),nossl)
    CMAKE_OPTIONS += -DLWS_WITH_SSL=OFF
endif

ifeq ($(BUILD_VARIANT),openssl)
    CMAKE_OPTIONS += -DLWS_OPENSSL_CLIENT_CERTS=/etc/ssl/certs
    CMAKE_OPTIONS += -DLWS_WITH_SSL=ON
endif

ifeq ($(BUILD_VARIANT),cyassl)
    CMAKE_OPTIONS += -DLWS_OPENSSL_CLIENT_CERTS=/etc/ssl/certs
    CMAKE_OPTIONS += -DLWS_WITH_SSL=ON
# for cyassl, edit package/libs/cyassl/Makefile to include --enable-opensslextra
# NOTE: it will compile without it, untested whether it it's needed?!
    CMAKE_OPTIONS += -DLWS_USE_CYASSL=ON
    CMAKE_OPTIONS += -DLWS_CYASSL_LIBRARIES=$(STAGING_DIR)/usr/lib/libcyassl.so
    CMAKE_OPTIONS += -DLWS_CYASSL_INCLUDE_DIRS=$(STAGING_DIR)/usr/include
endif

ifeq ($(BUILD_VARIANT),full)
    CMAKE_OPTIONS += -DLWS_OPENSSL_CLIENT_CERTS=/etc/ssl/certs
    CMAKE_OPTIONS += -DLWS_WITH_SSL=ON
    CMAKE_OPTIONS += -DLWS_WITH_LIBUV=$(if $(CONFIG_PACKAGE_$(PKG_NAME)-$(BUILD_VARIANT)_libuv),ON,OFF)
    CMAKE_OPTIONS += -DLWS_WITH_CGI=$(if $(CONFIG_PACKAGE_$(PKG_NAME)-$(BUILD_VARIANT)_CGI),ON,OFF)
endif


CMAKE_OPTIONS += -DLWS_WITHOUT_TESTAPPS=ON
CMAKE_OPTIONS += -DLWS_IPV6=$(if $(CONFIG_IPV6),ON,OFF)

# other options worth noting
# CMAKE_OPTIONS += -DLWS_WITHOUT_EXTENSIONS=ON
# CMAKE_OPTIONS += -DLWS_WITHOUT_DAEMONIZE=ON
# CMAKE_OPTIONS += -DLWS_WITHOUT_SERVER=ON
# CMAKE_OPTIONS += -DLWS_WITHOUT_DEBUG=ON

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwebsockets.so* $(1)/usr/lib/
endef

Package/$(PKG_NAME)-nossl/install = $(Package/$(PKG_NAME)/install)
Package/$(PKG_NAME)-openssl/install = $(Package/$(PKG_NAME)/install)
Package/$(PKG_NAME)-cyassl/install = $(Package/$(PKG_NAME)/install)
Package/$(PKG_NAME)-full/install = $(Package/$(PKG_NAME)/install)

$(eval $(call BuildPackage,$(PKG_NAME)-nossl))
$(eval $(call BuildPackage,$(PKG_NAME)-openssl))
$(eval $(call BuildPackage,$(PKG_NAME)-cyassl))
$(eval $(call BuildPackage,$(PKG_NAME)-full))
