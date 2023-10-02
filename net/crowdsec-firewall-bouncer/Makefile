# SPDX-License-Identifier: MIT
#
# Copyright (C) 2021-2022 Gerald Kerma <gandalf@gk2.net>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=crowdsec-firewall-bouncer
PKG_VERSION:=0.0.28
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/crowdsecurity/cs-firewall-bouncer/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=1e0f4d3cd8bc73da21eafc9b965fda0c1c1b0a27a2acc038004602797e4fccf0

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Gerald Kerma <gandalf@gk2.net>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_DIR:=$(BUILD_DIR)/cs-firewall-bouncer-$(PKG_VERSION)

CSFB_BUILD_VERSION?=v$(PKG_VERSION)
CSFB_BUILD_GOVERSION:=$(shell go version | cut -d " " -f3 | sed -E 's/[go]+//g')
CSFB_BUILD_TIMESTAMP:=$(shell date +%F"_"%T)
CSFB_BUILD_TAG:=openwrt-$(PKG_VERSION)-$(PKG_RELEASE)
CSFB_VERSION_PKG:=github.com/crowdsecurity/cs-firewall-bouncer/pkg/version

GO_PKG:=github.com/crowdsecurity/cs-firewall-bouncer
GO_PKG_INSTALL_ALL:=1
GO_PKG_LDFLAGS_X:=$(CSFB_VERSION_PKG).Version=$(CSFB_BUILD_VERSION) \
	$(CSFB_VERSION_PKG).BuildDate=$(CSFB_BUILD_TIMESTAMP) \
	$(CSFB_VERSION_PKG).Tag=$(CSFB_BUILD_TAG) \
	$(CSFB_VERSION_PKG).GoVersion=$(CSFB_BUILD_GOVERSION)

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
  DEPENDS:=$(GO_ARCH_DEPENDS)
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

  You must install nftables.
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

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/crowdsec.config $(1)/etc/config/crowdsec

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/crowdsec-firewall-bouncer.initd $(1)/etc/init.d/crowdsec-firewall-bouncer
endef

define Package/crowdsec-firewall-bouncer/conffiles
/etc/config/crowdsec
endef

$(eval $(call GoBinPackage,crowdsec-firewall-bouncer))
$(eval $(call BuildPackage,crowdsec-firewall-bouncer))
