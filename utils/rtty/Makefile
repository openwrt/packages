#
# Copyright (C) 2018 Jianhui Zhao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rtty
PKG_VERSION:=4.1.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL=https://github.com/zhaojh329/rtty.git
PKG_MIRROR_HASH:=2689ffafc7a6b2e649173edff802ec6d7c8476f1998497fca36a26c21fdcdc1c

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_SOURCE_SUBDIR)

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Jianhui Zhao <jianhuizhao329@gmail.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/rtty/default
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Terminal
  TITLE:=A reverse proxy WebTTY
  DEPENDS:=+libblobmsg-json
endef

define Package/rtty/default/description
A reverse proxy WebTTY. This is the client part running on devices to be managed.
endef

define Package/rtty-nossl
  $(Package/rtty/default)
  TITLE += (NO SSL)
  DEPENDS += +libuwsc-nossl
  VARIANT:=nossl
  CONFLICTS:=rtty-openssl rtty-wolfssl rtty-mbedtls
endef

define Package/rtty-openssl
  $(Package/rtty/default)
  TITLE += (openssl)
  DEPENDS += +libuwsc-openssl
  VARIANT:=openssl
  CONFLICTS:=rtty-wolfssl rtty-mbedtls
endef

define Package/rtty-wolfssl
  $(Package/rtty/default)
  TITLE += (wolfssl)
  DEPENDS += +libuwsc-wolfssl
  VARIANT:=wolfssl
  CONFLICTS:=rtty-mbedtls
endef

define Package/rtty-mbedtls
  $(Package/rtty/default)
  TITLE += (mbedtls)
  DEPENDS += +libuwsc-mbedtls
  VARIANT:=mbedtls
endef

Package/rtty-nossl/description = $(Package/rtty/default/description)
Package/rtty-openssl/description = $(Package/rtty/default/description)
Package/rtty-wolfssl/description = $(Package/rtty/default/description)
Package/rtty-mbedtls/description = $(Package/rtty/default/description)

define Package/rtty/default/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/rtty $(1)/usr/sbin
	$(INSTALL_BIN) ./files/rtty.init $(1)/etc/init.d/rtty
	$(INSTALL_CONF) ./files/rtty.config $(1)/etc/config/rtty
endef

Package/rtty-nossl/install = $(Package/rtty/default/install)
Package/rtty-openssl/install = $(Package/rtty/default/install)
Package/rtty-wolfssl/install = $(Package/rtty/default/install)
Package/rtty-mbedtls/install = $(Package/rtty/default/install)

$(eval $(call BuildPackage,rtty-nossl))
$(eval $(call BuildPackage,rtty-mbedtls))
$(eval $(call BuildPackage,rtty-wolfssl))
$(eval $(call BuildPackage,rtty-openssl))

