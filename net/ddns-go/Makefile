# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021-2026 sirpdboy  <herboy2008@gmail.com>
# 

include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-go
PKG_VERSION:=6.16.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jeessy2/ddns-go/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=1a92f53e50c8ca81e20c15c6dbaf490544f1a7b7b8c8d1c4c60ad8f1bc890276

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=sirpdboy <herboy2008@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/jeessy2/ddns-go/v6
GO_PKG_LDFLAGS_X:=main.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/ddns-go
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Support IPV4 and IPV6 simple and easy-to-use IP binding domain name tool
  URL:=https://github.com/jeessy2/ddns-go
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
  USERID:=ddns-go:ddns-go
endef

define Package/ddns-go/description
  A simple and easy-to-use IP binding domain name tool that supports IPV4 and IPV6.
endef

define Package/ddns-go/conffiles
/etc/config/ddns-go
/etc/ddns-go/ddns-go-config.yaml
endef


define Package/ddns-go/install
	$(call GoPackage/Package/Install/Bin,$(1))	
	$(INSTALL_DIR) $(1)/etc/init.d	
	$(INSTALL_DIR) $(1)/etc/config	
	$(INSTALL_DIR) $(1)/etc/ddns-go	
	[ -f $(CURDIR)/files/ddns-go.init ] && $(INSTALL_BIN) $(CURDIR)/files/ddns-go.init $(1)/etc/init.d/ddns-go || true	
	[ -f $(CURDIR)/files/ddns-go.conf ] && $(INSTALL_CONF) $(CURDIR)/files/ddns-go.conf $(1)/etc/config/ddns-go || true	
endef

$(eval $(call GoBinPackage,ddns-go))
$(eval $(call BuildPackage,ddns-go))