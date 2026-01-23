# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=dnsproxy
PKG_VERSION:=0.78.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/AdguardTeam/dnsproxy/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=dabb78173f518da7c2a5394cf52e3f6cdd09d9cb48f3dafa59f5b5788459bf75

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/AdguardTeam/dnsproxy
GO_PKG_LDFLAGS_X:=$(GO_PKG)/internal/version.version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/dnsproxy
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Simple DNS proxy with DoH, DoT, DoQ and DNSCrypt support
  URL:=https://github.com/AdguardTeam/dnsproxy
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
  USERID:=dnsproxy=411:dnsproxy=411
endef

define Package/dnsproxy/description
  A simple DNS proxy server that supports all existing DNS protocols including
  DNS-over-TLS, DNS-over-HTTPS, DNSCrypt, and DNS-over-QUIC.Moreover, it can
  work as a DNS-over-HTTPS, DNS-over-TLS or DNS-over-QUIC server.
endef

define Package/dnsproxy/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/capabilities/
	$(INSTALL_DATA) $(CURDIR)/files/dnsproxy.json $(1)/etc/capabilities/dnsproxy.json
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/dnsproxy.config $(1)/etc/config/dnsproxy
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/dnsproxy.init $(1)/etc/init.d/dnsproxy
	$(INSTALL_DIR) $(1)/etc/uci-defaults/
	$(INSTALL_BIN) $(CURDIR)/files/dnsproxy.defaults $(1)/etc/uci-defaults/80-dnsproxy-migration
	$(INSTALL_DIR) $(1)/etc/sysctl.d/
	$(INSTALL_CONF) ./files/dnsproxy.sysctl $(1)/etc/sysctl.d/50-dnsproxy.conf
endef

define Package/dnsproxy/conffiles
/etc/config/dnsproxy
endef

$(eval $(call GoBinPackage,dnsproxy))
$(eval $(call BuildPackage,dnsproxy))
