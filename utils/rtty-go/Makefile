#
# Copyright (C) 2025 Jianhui Zhao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rtty-go
PKG_VERSION:=1.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/zhaojh329/rtty-go/tar.gz/v${PKG_VERSION}?
PKG_HASH:=e893c3ccedcadb078d620296080f21fec6cc78d5c74c7ecde4f4944bd6cb240d

PKG_MAINTAINER:=Jianhui Zhao <zhaojh329@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/zhaojh329/rtty-go

GO_PKG_LDFLAGS_X:=main.BuildTime=$(date +%FT%T%z)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/rtty-go
  TITLE:=Access your terminals from anywhere via the web
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Terminal
  URL:=https://github.com/zhaojh329/rtty-go
  DEPENDS:=$(GO_ARCH_DEPENDS)
  CONFLICTS:=rtty-mbedtls rtty-openssl rtty-wolfssl rtty-nossl
endef

define Package/rtty-go/description
  This is a Go language rewrite of the original C-based rtty remote terminal client.
endef

define Package/rtty-go/conffiles
/etc/config/rtty
endef

define Package/rtty-go/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/rtty-go $(1)/usr/sbin/rtty
	$(INSTALL_BIN) ./files/rtty.init $(1)/etc/init.d/rtty
	$(INSTALL_CONF) ./files/rtty.config $(1)/etc/config/rtty
endef

$(eval $(call BuildPackage,rtty-go))
