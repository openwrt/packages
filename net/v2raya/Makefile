# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=v2rayA
PKG_VERSION:=2.2.7.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/v2rayA/v2rayA/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=801a5488493cef8c2603d596e5982d226c07ad8f4a2969d942922be79169ec29
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/service

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/v2rayA/v2rayA
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/conf.Version=$(PKG_VERSION) \
	$(GO_PKG)/core/iptables.TproxyNotSkipBr=true

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1)/.. $(TAR_OPTIONS)

define Package/v2raya
  TITLE:=A Linux web GUI client of Project V
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  DEPENDS:=$(GO_ARCH_DEPENDS) \
    +ca-bundle \
    +kmod-nft-tproxy \
    +xray-core
  URL:=https://v2raya.org
endef

define Package/v2raya/description
  v2rayA is a V2Ray Linux client supporting global transparent proxy,
  compatible with SS, SSR, Trojan(trojan-go), PingTunnel protocols.
endef

define Package/v2raya/conffiles
/etc/v2raya/
/etc/config/v2raya
endef

WEB_FILE:=$(PKG_NAME)-web-$(PKG_VERSION).tar.gz
define Download/v2raya-web
	URL:=https://github.com/v2rayA/v2rayA/releases/download/v$(PKG_VERSION)/
	URL_FILE:=web.tar.gz
	FILE:=$(WEB_FILE)
	HASH:=985b083a75b7b34ea9c5151cbc096f6f44fa369a807fea85b435fed5229dae65
endef

define Build/Prepare
	$(call Build/Prepare/Default)

	( \
		mkdir -p $(PKG_BUILD_DIR)/server/router/web ; \
		gzip -dc $(DL_DIR)/$(WEB_FILE) | $(HOST_TAR) -C $(PKG_BUILD_DIR)/server/router/web $(TAR_OPTIONS) ; \
	)
endef

define Package/v2raya/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/v2rayA $(1)/usr/bin/v2raya

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/v2raya.config $(1)/etc/config/v2raya
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/v2raya.init $(1)/etc/init.d/v2raya
endef

$(eval $(call Download,v2raya-web))
$(eval $(call GoBinPackage,v2raya))
$(eval $(call BuildPackage,v2raya))
