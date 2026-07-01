#
# Copyright (C) 2026 Florian Klink
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=swgp-go
PKG_VERSION:=1.10.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/database64128/swgp-go/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=0d7e5ebce9c07237e71028eac31b27c51d155c5a72eefc7bceac4cc816725d23

PKG_MAINTAINER:=Florian Klink <flokli@flokli.de>
PKG_LICENSE:=AGPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/swgp-go-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/database64128/swgp-go
GO_PKG_TAGS:=swgpgo_nopprof

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/swgp-go
  SECTION:=net
  CATEGORY:=Network
  TITLE:= Simple WireGuard proxy
  URL:= https://github.com/database64128/swgp-go
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/swgp-go/description
  Simple WireGuard proxy with minimal overhead for WireGuard traffic.
endef

define Package/swgp-go/conffiles
/etc/swgp-go.json
endef

define Package/swgp-go/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/swgp-go $(1)/usr/sbin
	$(INSTALL_BIN) ./files//swgp-go.init $(1)/etc/init.d/swgp-go
	$(INSTALL_DATA) ./files//swgp-go.json $(1)/etc/swgp-go.json
endef

$(eval $(call BuildPackage,swgp-go))
