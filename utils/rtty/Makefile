#
# Copyright (C) 2018 Jianhui Zhao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rtty
PKG_VERSION:=9.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL=https://github.com/zhaojh329/rtty/releases/download/v$(PKG_VERSION)
PKG_HASH:=5137cbe2f58588851376f2e74ded7f570320bd7cfc437d47d2485fb4be5042a1

PKG_MAINTAINER:=Jianhui Zhao <zhaojh329@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/rtty/Default
  TITLE:=Access your terminals from anywhere via the web
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Terminal
  URL:=https://github.com/zhaojh329/rtty
  DEPENDS:=+libev $(2)
  VARIANT:=$(1)
  PROVIDES:=rtty
endef

Package/rtty-openssl=$(call Package/rtty/Default,openssl,+PACKAGE_rtty-openssl:libopenssl)
Package/rtty-wolfssl=$(call Package/rtty/Default,wolfssl,+PACKAGE_rtty-wolfssl:libwolfssl)
Package/rtty-mbedtls=$(call Package/rtty/Default,mbedtls,+PACKAGE_rtty-mbedtls:libmbedtls +PACKAGE_rtty-mbedtls:zlib)
Package/rtty-nossl=$(call Package/rtty/Default,nossl)

define Package/rtty-openssl/conffiles
/etc/config/rtty
endef

Package/rtty-wolfssl/conffiles = $(Package/rtty-openssl/conffiles)
Package/rtty-mbedtls/conffiles = $(Package/rtty-openssl/conffiles)
Package/rtty-nossl/conffiles = $(Package/rtty-openssl/conffiles)

ifeq ($(BUILD_VARIANT),openssl)
  CMAKE_OPTIONS += -DUSE_OPENSSL=ON
else ifeq ($(BUILD_VARIANT),wolfssl)
  CMAKE_OPTIONS += -DUSE_WOLFSSL=ON
else ifeq ($(BUILD_VARIANT),mbedtls)
  CMAKE_OPTIONS += -DUSE_MBEDTLS=ON
else
  CMAKE_OPTIONS += -DSSL_SUPPORT=OFF
endif

define Package/rtty-$(BUILD_VARIANT)/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/rtty $(1)/usr/sbin
	$(INSTALL_BIN) ./files/rtty.init $(1)/etc/init.d/rtty
	$(INSTALL_CONF) ./files/rtty.config $(1)/etc/config/rtty
endef

$(eval $(call BuildPackage,rtty-openssl))
$(eval $(call BuildPackage,rtty-wolfssl))
$(eval $(call BuildPackage,rtty-mbedtls))
$(eval $(call BuildPackage,rtty-nossl))
