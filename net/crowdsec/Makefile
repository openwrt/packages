# SPDX-License-Identifier: MIT
#
# Copyright (C) 2021-2022 Gerald Kerma <gandalf@gk2.net>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=crowdsec
PKG_VERSION:=1.3.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/crowdsecurity/crowdsec/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b81419d9a1af500c16a02f052ac6af54253a621ee1575131dfae0f578426d816

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Gerald Kerma <gandalf@gk2.net>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

CWD_SYSTEM:=openwrt

CWD_BUILD_VERSION?=v$(PKG_VERSION)
CWD_BUILD_GOVERSION:=$(shell go version | cut -d " " -f3 | sed -E 's/[go]+//g')
CWD_BUILD_CODENAME:=alphaga
CWD_BUILD_TIMESTAMP:=$(shell date +%F"_"%T)
CWD_BUILD_TAG:=openwrt-$(PKG_VERSION)-$(PKG_RELEASE)

CWD_VERSION_PKG:=github.com/crowdsecurity/crowdsec/pkg/cwversion

GO_PKG:=github.com/crowdsecurity/crowdsec
GO_PKG_INSTALL_ALL:=1
GO_PKG_LDFLAGS_X:=$(CWD_VERSION_PKG).Version=$(CWD_BUILD_VERSION) \
	$(CWD_VERSION_PKG).System=$(CWD_SYSTEM) \
	$(CWD_VERSION_PKG).BuildDate=$(CWD_BUILD_TIMESTAMP) \
	$(CWD_VERSION_PKG).Codename=$(CWD_BUILD_CODENAME)  \
	$(CWD_VERSION_PKG).Tag=$(CWD_BUILD_TAG) \
	$(CWD_VERSION_PKG).GoVersion=$(CWD_BUILD_GOVERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/crowdsec/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Crowdsec detection engine
  URL:=https://crowdsec.net/
endef

define Package/crowdsec
$(call Package/crowdsec/Default)
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/golang-crowdsec-dev
$(call Package/crowdsec/Default)
$(call GoPackage/GoSubMenu)
  TITLE+= (source files)
  DEPENDS:=$(GO_ARCH_DEPENDS)
  PKGARCH:=all
endef

define Package/crowdsec/Default/description
  Crowdsec - An open-source, lightweight agent to detect
  and respond to bad behaviours.
  It also automatically benefits from a global
  community-wide IP reputation database.
endef

define Package/crowdsec/description
$(call Package/crowdsec/Default/description)

  This package contains the main program.
endef

define Package/golang-crowdsec-dev/description
$(call Package/crowdsec/Default/description)

  This package provides the source files for the program.
endef

define Package/crowdsec/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/crowdsec
	$(INSTALL_DIR) $(1)/etc/crowdsec/scenarios
	$(INSTALL_DIR) $(1)/etc/crowdsec/postoverflows
	$(INSTALL_DIR) $(1)/etc/crowdsec/collections
	$(INSTALL_DIR) $(1)/etc/crowdsec/patterns
	$(INSTALL_DIR) $(1)/etc/crowdsec/hub

	$(INSTALL_DATA) \
		$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/config.yaml \
		$(1)/etc/crowdsec
	$(INSTALL_DATA) \
		$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/dev.yaml \
		$(1)/etc/crowdsec
	$(INSTALL_DATA) \
		$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/user.yaml \
		$(1)/etc/crowdsec
	$(INSTALL_DATA) \
		$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/acquis.yaml \
		$(1)/etc/crowdsec
	$(INSTALL_DATA) \
		$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/profiles.yaml \
		$(1)/etc/crowdsec
	$(INSTALL_DATA) \
		$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/simulation.yaml \
		$(1)/etc/crowdsec
	$(INSTALL_DATA) \
		$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/local_api_credentials.yaml \
		$(1)/etc/crowdsec
	$(INSTALL_DATA) \
		$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/online_api_credentials.yaml \
		$(1)/etc/crowdsec

	$(CP) \
		$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/patterns/* \
		$(1)/etc/crowdsec/patterns

	$(INSTALL_DIR) $(1)/srv/crowdsec/data/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) \
		./files/crowdsec.initd \
		$(1)/etc/init.d/crowdsec

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) \
		./files/crowdsec.config \
		$(1)/etc/config/crowdsec

	$(LN) /usr/bin/crowdsec-cli $(1)/usr/bin/cscli

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) \
		./files/crowdsec.defaults \
		$(1)/etc/uci-defaults/99_crowdsec
endef

define Package/crowdsec/conffiles
/etc/crowdsec/
/etc/config/crowdsec
endef

$(eval $(call GoBinPackage,crowdsec))
$(eval $(call BuildPackage,crowdsec))
