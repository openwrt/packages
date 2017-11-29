#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libuhttp
PKG_VERSION:=0.2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://codeload.github.com/zhaojh329/libuhttp/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=d1d2639af4fcd802870c4522d4fba4c8346683317c0a0f4a56579db327a83059

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_SOURCE_SUBDIR)

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# CMAKE_OPTIONS += -DUHTTP_DEBUG=1

define Package/libuhttp/Default
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Networking
  TITLE:=libuhttp
  DEPENDS:=+libev
  URL:=https://github.com/zhaojh329/libuhttp
  MAINTAINER:=Jianhui Zhao <jianhuizhao329@gmail.com>
endef

define Package/libuhttp-openssl
	$(call Package/libuhttp/Default)
	TITLE += (OpenSSL)
	DEPENDS += +libopenssl
	VARIANT:=openssl
endef

define Package/libuhttp-cyassl
	$(call Package/$(PKG_NAME)/Default)
	TITLE += (CyaSSL)
	DEPENDS += +libcyassl
	VARIANT:=cyassl
endef

define Package/libuhttp-nossl
	$(call Package/libuhttp/Default)
	TITLE += (NO SSL)
	VARIANT:=nossl
endef

ifeq ($(BUILD_VARIANT),openssl)
    CMAKE_OPTIONS += -DUHTTP_USE_OPENSSL=1
endif

ifeq ($(BUILD_VARIANT),cyassl)
    CMAKE_OPTIONS += -DUHTTP_USE_CYASSL=1
endif

ifeq ($(BUILD_VARIANT),nossl)
    CMAKE_OPTIONS += -DUHTTP_DISABLE_SSL=1
endif

define Package/libuhttp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libuhttp.so* $(1)/usr/lib/
endef

Package/libuhttp-openssl/install = $(Package/libuhttp/install)
Package/libuhttp-cyassl/install = $(Package/libuhttp/install)
Package/libuhttp-nossl/install = $(Package/libuhttp/install)

$(eval $(call BuildPackage,libuhttp-openssl))
$(eval $(call BuildPackage,libuhttp-cyassl))
$(eval $(call BuildPackage,libuhttp-nossl))
