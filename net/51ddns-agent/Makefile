# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2026 51DDNS

include $(TOPDIR)/rules.mk

PKG_NAME:=51ddns-agent
PKG_VERSION:=0.6.2
PKG_RELEASE:=1

PKG_SOURCE:=51ddns-openwrt-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/21hkcloud/51ddns-openwrt/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=674bcd1121e4105a0c505fb08a15a3b8bc3dd33d75d8f312df696fc4be9be239
PKG_BUILD_DIR:=$(BUILD_DIR)/51ddns-openwrt-$(PKG_VERSION)

PKG_MAINTAINER:=Jinshuan Wang <21hkcloud@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/21hkcloud/51ddns-openwrt
GO_PKG_BUILD_PKG:=$(GO_PKG)/cmd/51ddns-agent
GO_PKG_LDFLAGS_X:=main.agentVersion=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/51ddns-agent
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=Client for the 51DDNS remote access cloud
  URL:=https://github.com/21hkcloud/51ddns-openwrt
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle +frpc
  USERID:=ddns51:ddns51
endef

define Package/51ddns-agent/description
  Client for the vendor-hosted 51DDNS remote access service. It contacts
  api.51ddns.com and starts feed-provided frpc processes from authenticated
  tunnel configurations assigned through the user's 51DDNS account.
endef

define Package/51ddns-agent/conffiles
/etc/config/51ddns
endef

define Package/51ddns-agent/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/51ddns-agent $(1)/usr/bin/51ddns-agent
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/51ddns.config $(1)/etc/config/51ddns
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/51ddns-agent.init $(1)/etc/init.d/51ddns-agent
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) ./files/51ddns-agent-start $(1)/usr/libexec/51ddns-agent-start
	$(INSTALL_DIR) $(1)/etc/51ddns
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/51ddns-agent.upgrade $(1)/lib/upgrade/keep.d/51ddns-agent
endef

$(eval $(call BuildPackage,51ddns-agent))
