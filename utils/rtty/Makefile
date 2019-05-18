#
# Copyright (C) 2018 Jianhui Zhao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rtty
PKG_VERSION:=6.6.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL=https://codeload.github.com/zhaojh329/rtty/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=4a46bd80f738ccb9aeea7c0cb8aa5ac364fd964d9ccc1bc3faf7b68eae17007c
CMAKE_INSTALL:=1

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_SOURCE_SUBDIR)

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Jianhui Zhao <jianhuizhao329@gmail.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/rtty/Default
  TITLE:=Access your terminals from anywhere via the web
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Terminal
  URL:=https://github.com/zhaojh329/rtty
  DEPENDS:=$(2)
  VARIANT:=$(1)
  PROVIDES:=rtty
endef

Package/rtty-openssl=$(call Package/rtty/Default,openssl,+PACKAGE_rtty-openssl:libuwsc-openssl)
Package/rtty-wolfssl=$(call Package/rtty/Default,wolfssl,+PACKAGE_rtty-wolfssl:libuwsc-wolfssl)
Package/rtty-mbedtls=$(call Package/rtty/Default,mbedtls,+PACKAGE_rtty-mbedtls:libuwsc-mbedtls)
Package/rtty-nossl=$(call Package/rtty/Default,nossl,+PACKAGE_rtty-nossl:libuwsc-nossl)

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
