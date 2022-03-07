# SPDX-License-Identifier: MIT
#
# Copyright (C) 2021-2022 Gerald Kerma <gandalf@gk2.net>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=crowdsec
PKG_VERSION:=1.3.2
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/crowdsecurity/crowdsec/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=2e237c58d5ea4fe4b76866b98645d339f65f76ce18fddd130b915ec1b59a610d

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Gerald Kerma <gandalf@gk2.net>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

CWD_CONFIGPATH:=/etc/crowdsec
CWD_DATAPATH:=/srv/crowdsec/data

CWD_VARS += BUILD_VERSION="v$(PKG_VERSION)"
CWD_VARS += BUILD_TAG="openwrt-$(PKG_VERSION)-$(PKG_RELEASE)"
CWD_VARS += BUILD_GOVERSION="$(shell go version | cut -d " " -f3 | sed -E 's/[go]+//g')"
CWD_VARS += BUILD_CODENAME="alphaga"
CWD_VARS += BUILD_TIMESTAMP="$(shell date +%F"_"%T)"
CWD_VARS += DEFAULT_CONFIGDIR="${CWD_CONFIGPATH}"
CWD_VARS += DEFAULT_DATADIR="$(CWD_DATAPATH)"

GO_PKG:=github.com/crowdsecurity/crowdsec
GO_PKG_INSTALL_ALL:=1

CGO_ENABLED = 1
##GO111MODULE = on

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

define Package/crowdsec-cli
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Crowdsec detection engine (cscli command line only)
  URL:=https://crowdsec.net/
  DEPENDS:=$(GO_ARCH_DEPENDS)
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

define Package/crowdsec-cli/description
$(call Package/crowdsec/Default/description)

  This package provides only the cscli command line tool.
endef

define Package/crowdsec/Default/install

	# CONFIG DIRECTORIES
		$(INSTALL_DIR) $(1)$(CWD_CONFIGPATH)
		$(INSTALL_DIR) $(1)$(CWD_CONFIGPATH)/bouncers
		$(INSTALL_DIR) $(1)$(CWD_CONFIGPATH)/collections
		$(INSTALL_DIR) $(1)$(CWD_CONFIGPATH)/hub
		$(INSTALL_DIR) $(1)$(CWD_CONFIGPATH)/notifications
		$(INSTALL_DIR) $(1)$(CWD_CONFIGPATH)/patterns
		$(INSTALL_DIR) $(1)$(CWD_CONFIGPATH)/postoverflows
		$(INSTALL_DIR) $(1)$(CWD_CONFIGPATH)/scenarios

	# CONFIG FILES
		$(INSTALL_DATA) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/config.yaml \
			$(1)$(CWD_CONFIGPATH)
		$(INSTALL_DATA) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/dev.yaml \
			$(1)$(CWD_CONFIGPATH)
		$(INSTALL_DATA) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/user.yaml \
			$(1)$(CWD_CONFIGPATH)
		$(INSTALL_DATA) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/acquis.yaml \
			$(1)$(CWD_CONFIGPATH)
		$(INSTALL_DATA) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/profiles.yaml \
			$(1)$(CWD_CONFIGPATH)
		$(INSTALL_DATA) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/simulation.yaml \
			$(1)$(CWD_CONFIGPATH)
		$(INSTALL_DATA) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/local_api_credentials.yaml \
			$(1)$(CWD_CONFIGPATH)
		$(INSTALL_DATA) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/online_api_credentials.yaml \
			$(1)$(CWD_CONFIGPATH)

	# CONFIG PATTERNS
		$(CP) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/config/patterns/* \
			$(1)$(CWD_CONFIGPATH)/patterns

	# PLUGINS BINARIES
		$(INSTALL_DIR) $(1)/usr/lib/crowdsec/plugins
		$(INSTALL_BIN) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/plugins/notifications/slack/notification-slack \
			$(1)/usr/lib/crowdsec/plugins
		$(INSTALL_BIN) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/plugins/notifications/http/notification-http \
			$(1)/usr/lib/crowdsec/plugins
		$(INSTALL_BIN) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/plugins/notifications/splunk/notification-splunk \
			$(1)/usr/lib/crowdsec/plugins
		$(INSTALL_BIN) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/plugins/notifications/email/notification-email \
			$(1)/usr/lib/crowdsec/plugins

	# PLUGINS CONFIG
		$(INSTALL_DATA) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/plugins/notifications/slack/slack.yaml \
			$(1)$(CWD_CONFIGPATH)/notifications/slack.yaml
		$(INSTALL_DATA) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/plugins/notifications/http/http.yaml \
			$(1)$(CWD_CONFIGPATH)/notifications/http.yaml
		$(INSTALL_DATA) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/plugins/notifications/splunk/splunk.yaml \
			$(1)$(CWD_CONFIGPATH)/notifications/splunk.yaml
		$(INSTALL_DATA) \
			$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/plugins/notifications/email/email.yaml \
			$(1)$(CWD_CONFIGPATH)/notifications/email.yaml

	# DATA
		$(INSTALL_DIR) $(1)$(CWD_DATAPATH)

endef

define Package/crowdsec/install

	$(call Package/crowdsec/Default/install,$1)

	# INIT.D SERVICE
		$(INSTALL_DIR) $(1)/etc/init.d
		$(INSTALL_BIN) \
			./files/crowdsec.initd \
			$(1)/etc/init.d/$(PKG_NAME)

	# BINARIES
		$(INSTALL_DIR) $(1)/usr/bin/
		$(INSTALL_BIN) $(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/cmd/crowdsec/crowdsec \
			$(1)/usr/bin/crowdsec
		$(INSTALL_BIN) $(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/cmd/crowdsec-cli/cscli \
			$(1)/usr/bin/cscli

	# UCI-CONFIG (POSTUPGRADE/POSTINSTALL)
		$(INSTALL_DIR) $(1)/etc/config
		$(INSTALL_CONF) \
			./files/crowdsec.config \
			$(1)/etc/config/$(PKG_NAME)

	# UCI-DEFAULTS (POSTUPGRADE/POSTINSTALL)
		$(INSTALL_DIR) $(1)/etc/uci-defaults
		$(INSTALL_BIN) \
			./files/crowdsec.defaults \
			$(1)/etc/uci-defaults/99_crowdsec

endef

define Package/crowdsec-cli/install

	$(call Package/crowdsec/Default/install,$1)

	# BINARIES
		$(INSTALL_DIR) $(1)/usr/bin/
		$(INSTALL_BIN) $(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/cmd/crowdsec-cli/cscli \
			$(1)/usr/bin/cscli

endef

define Package/crowdsec/conffiles
/etc/crowdsec/
/etc/config/crowdsec
endef

define Package/crowdsec-cli/conffiles
/etc/crowdsec/
/etc/config/crowdsec
endef

# Reset golang-package.mk overrides so we can use the Makefile
MAKE_VARS += $(GO_PKG_VARS)
MAKE_VARS += $(CWD_VARS)
MAKE_PATH:=$(GO_PKG_WORK_DIR_NAME)/build/src/$(GO_PKG)
Build/Compile=$(call Build/Compile/Default)

$(eval $(call BuildPackage,crowdsec))
$(eval $(call BuildPackage,crowdsec-cli))