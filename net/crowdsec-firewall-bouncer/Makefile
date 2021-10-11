# SPDX-License-Identifier: MIT
#
# Copyright (C) 2021 Gerald Kerma
#

include $(TOPDIR)/rules.mk

PKG_NAME:=crowdsec-firewall-bouncer
PKG_VERSION:=0.0.15
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/crowdsecurity/cs-firewall-bouncer
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_DATE:=2021903
PKG_MIRROR_HASH:=2ef7e4f935056d648a6b45bb09ebb5846262ac9d745229b1442051abdd214c86

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Gerald Kerma <gandalf@gk2.net>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

CSFB_BUILD_VERSION?=$(PKG_SOURCE_VERSION)
CSFB_BUILD_GOVERSION=$(shell go version | cut -d " " -f3 | sed -r 's/[go]+//g')
CWD_BUILD_TIMESTAMP:=$(SOURCE_DATE_EPOCH)
CSFB_BUILD_TAG=openwrt

CSFB_VERSION_PKG:=github.com/crowdsecurity/cs-firewall-bouncer/pkg/version

GO_PKG:=github.com/crowdsecurity/cs-firewall-bouncer

GO_PKG_LDFLAGS_X:=$(CSFB_VERSION_PKG).Version=$(CSFB_BUILD_VERSION) \
	$(CSFB_VERSION_PKG).BuildDate=$(CSFB_BUILD_TIMESTAMP) \
	$(CSFB_VERSION_PKG).Tag=$(CSFB_BUILD_TAG) \
	$(CSFB_VERSION_PKG).GoVersion=$(CSFB_BUILD_GOVERSION)

GO_PKG_INSTALL_ALL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/crowdsec-firewall-bouncer/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Firewall bouncer for Crowdsec
  URL:=https://github.com/crowdsecurity/cs-firewall-bouncer/
endef

define Package/crowdsec-firewall-bouncer
$(call Package/crowdsec-firewall-bouncer/Default)
  DEPENDS:=@(PACKAGE_iptables||PACKAGE_nftables) \
	$(GO_ARCH_DEPENDS) \
	+crowdsec
endef

define Package/golang-crowdsec-firewall-bouncer-dev
$(call Package/crowdsec-firewall-bouncer/Default)
$(call GoPackage/GoSubMenu)
  TITLE+= (source files)
  DEPENDS:=$(GO_ARCH_DEPENDS)
  PKGARCH:=all
endef

define Package/crowdsec-firewall-bouncer/Default/description
  Crowdsec bouncer written in golang for firewalls.

  crowdsec-firewall-bouncer will fetch new and old decisions
  from a CrowdSec API to add them in a blocklist used by supported firewalls.

  You must install iptables+ipset or nftables.
endef

define Package/crowdsec-firewall-bouncer/description
$(call Package/crowdsec-firewall-bouncer/Default/description)

  This package contains the main program.
endef

define Package/golang-crowdsec-firewall-bouncer-dev/description
$(call Package/crowdsec-firewall-bouncer/Default/description)

  This package provides the source files for the program.
endef

define Package/crowdsec-firewall-bouncer/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/crowdsec/bouncers
	$(INSTALL_DATA) \
		$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/crowdsec-firewall-bouncer.yaml \
		$(1)/etc/crowdsec/bouncers

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) \
		./files/crowdsec-firewall-bouncer.initd \
		$(1)/etc/init.d/crowdsec-firewall-bouncer

	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) \
		./files/crowdsec-firewall-bouncer.firewall \
		$(1)/etc/firewall.cs

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) \
		./files/crowdsec-firewall-bouncer.defaults \
		$(1)/etc/uci-defaults/99_crowdsec-firewall-bouncer
endef

define Package/crowdsec-firewall-bouncer/conffiles
/etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
endef

$(eval $(call GoBinPackage,crowdsec-firewall-bouncer))
$(eval $(call BuildPackage,crowdsec-firewall-bouncer))
