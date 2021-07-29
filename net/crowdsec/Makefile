# SPDX-License-Identifier: MIT
#
# Copyright (C) 2021 Gerald Kerma
#

include $(TOPDIR)/rules.mk

PKG_NAME:=crowdsec
PKG_VERSION:=1.2.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/crowdsecurity/crowdsec
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_DATE:=20210914
PKG_MIRROR_HASH:=911af2c49c28596256c31ebb26b48c5ba9e6a0abdd46830e75e2cf4c0eff4256

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Gerald Kerma <gandalf@gk2.net>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

CWD_SYSTEM:=openwrt
CWD_BUILD_VERSION?=$(PKG_SOURCE_VERSION)
CWD_BUILD_GOVERSION:=$(shell go version | cut -d " " -f3 | sed -E 's/[go]+//g')
CWD_BUILD_CODENAME:=alphaga
CWD_BUILD_TIMESTAMP:=$(SOURCE_DATE_EPOCH)
CWD_BUILD_TAG:=openwrt

CWD_VERSION_PKG:=github.com/crowdsecurity/crowdsec/pkg/cwversion

GO_PKG:=github.com/crowdsecurity/crowdsec

GO_PKG_LDFLAGS_X:=$(CWD_VERSION_PKG).Version=$(CWD_BUILD_VERSION) \
	$(CWD_VERSION_PKG).System=$(CWD_SYSTEM) \
	$(CWD_VERSION_PKG).BuildDate=$(CWD_BUILD_TIMESTAMP) \
	$(CWD_VERSION_PKG).Codename=$(CWD_BUILD_CODENAME)  \
	$(CWD_VERSION_PKG).Tag=$(CWD_BUILD_TAG) \
	$(CWD_VERSION_PKG).GoVersion=$(CWD_BUILD_GOVERSION)

GO_PKG_INSTALL_ALL:=1

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
