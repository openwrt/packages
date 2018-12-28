#
# Copyright (C) 2018 Jianhui Zhao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libuwsc
PKG_VERSION:=3.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL=https://codeload.github.com/zhaojh329/libuwsc/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=24433f952faead4ace902f93895c02ebe0646c3a32487d7e94a0e47674349973
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jianhui Zhao <jianhuizhao329@gmail.com>
PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libuwsc/Default
  TITLE:=A lightweight WebSocket client library based on libev
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Networking
  URL:=https://github.com/zhaojh329/libuwsc
  DEPENDS:=+libev $(2)
  VARIANT:=$(1)
  PROVIDES:=libuwsc
endef

Package/libuwsc-openssl=$(call Package/libuwsc/Default,openssl,+PACKAGE_libuwsc-openssl:libopenssl)
Package/libuwsc-wolfssl=$(call Package/libuwsc/Default,wolfssl,+PACKAGE_libuwsc-wolfssl:libwolfssl)
Package/libuwsc-mbedtls=$(call Package/libuwsc/Default,mbedtls,+PACKAGE_libuwsc-mbedtls:libmbedtls)
Package/libuwsc-nossl=$(call Package/libuwsc/Default,nossl)

ifeq ($(BUILD_VARIANT),openssl)
  CMAKE_OPTIONS += -DUWSC_USE_OPENSSL=ON
else ifeq ($(BUILD_VARIANT),wolfssl)
  CMAKE_OPTIONS += -DUWSC_USE_WOLFSSL=ON
else ifeq ($(BUILD_VARIANT),mbedtls)
  CMAKE_OPTIONS += -DUWSC_USE_MBEDTLS=ON
else
  CMAKE_OPTIONS += -DUWSC_SSL_SUPPORT=OFF
endif

define Package/libuwsc-$(BUILD_VARIANT)/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libuwsc.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libuwsc-openssl))
$(eval $(call BuildPackage,libuwsc-wolfssl))
$(eval $(call BuildPackage,libuwsc-mbedtls))
$(eval $(call BuildPackage,libuwsc-nossl))
