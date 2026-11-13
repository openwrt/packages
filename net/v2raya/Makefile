# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org
# Copyright (C) 2026 Amr Fateem <amr.fateem@yahoo.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=v2rayA
PKG_VERSION:=2.5.13
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/v2rayA/v2rayA/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=20f03a9143231e2f04b74cdcb7125c6a44b450a4a28fac92b3e64c13916ec4d9
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/service

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=../LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>, Amr Fateem <amr.fateem@yahoo.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/v2rayA/v2rayA
GO_PKG_BUILD_PKG:=github.com/v2rayA/v2rayA
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/conf.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

# v2rayA's SQLite layer has a pure-Go driver for most architectures.  On
# mips and loong64 it falls back to mattn/go-sqlite3, which needs CGO.
V2RAYA_CGO:=0
ifneq ($(filter mips% loong64,$(GO_ARCH)),)
  V2RAYA_CGO:=1
endif

GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=$(V2RAYA_CGO)
ifeq ($(V2RAYA_CGO),0)
  GO_PKG_DEFAULT_LDFLAGS:=$(filter-out -linkmode external,$(GO_PKG_DEFAULT_LDFLAGS))
endif

TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1)/.. $(TAR_OPTIONS)

define Package/v2raya
  TITLE:=A Linux web GUI client of Project V
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  DEPENDS:=$(GO_ARCH_DEPENDS) \
    +v2raya-core \
    +ca-bundle \
    +nftables \
    +kmod-nft-tproxy \
    +ip-full \
    +kmod-tun
  URL:=https://v2raya.org
endef

define Package/v2raya/description
  v2rayA is a web client for its own Xray-based core.  It imports
  subscriptions and share links, selects the fastest node, and provides
  transparent proxy on Linux.

  This package installs the service together with the matching
  v2raya_core binary.
endef

define Package/v2raya/conffiles
/etc/config/v2raya
endef

WEB_FILE:=v2raya-web-$(PKG_VERSION).tar.gz
define Download/v2raya-web
	URL:=https://github.com/v2rayA/v2rayA/releases/download/v$(PKG_VERSION)/
	URL_FILE:=web.tar.gz
	FILE:=$(WEB_FILE)
	HASH:=76774f195ee74604fbc43a48fe74e5f3363e81ec68af02d1c26feeeacc0f63ae
endef

define Build/Prepare
	$(call Build/Prepare/Default)

	# The OpenWrt defaults (LAN bridge, DNS, logging) are carried in
	# patches/010-openwrt-defaults.patch so a changed source file fails
	# the build instead of silently dropping them.

	( \
		mkdir -p $(PKG_BUILD_DIR)/server/router/web ; \
		gzip -dc $(DL_DIR)/$(WEB_FILE) | $(HOST_TAR) -C $(PKG_BUILD_DIR)/server/router/web $(TAR_OPTIONS) ; \
	)
endef

define Package/v2raya/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/v2rayA $(1)/usr/bin/v2raya

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/v2raya.config $(1)/etc/config/v2raya

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/v2raya.init $(1)/etc/init.d/v2raya

	# Read-only detection helper used by the LuCI overview.  It only
	# reports installed cores and services; it never changes anything.
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(CURDIR)/files/v2raya-detect $(1)/usr/libexec/v2raya-detect

	# Keep the database and the web password across sysupgrade.  Listing
	# /etc/v2raya as an opkg conffile copies the whole directory and has
	# broken real upgrades.
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) $(CURDIR)/files/v2raya.keep $(1)/lib/upgrade/keep.d/v2raya
endef

$(eval $(call Download,v2raya-web))
$(eval $(call GoBinPackage,v2raya))
$(eval $(call BuildPackage,v2raya))
