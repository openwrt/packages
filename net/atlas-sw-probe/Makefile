#
# Copyright (C) 2019-2022 CZ.NIC z.s.p.o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=atlas-sw-probe
PKG_VERSION:=5120
PKG_RELEASE:=1

PKG_SOURCE:=ripe-atlas-software-probe-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/RIPE-NCC/ripe-atlas-software-probe/tar.gz/refs/tags/$(PKG_VERSION)?
PKG_HASH:=d399f793d1576d7856023c2fde69453a0e5dbd537b03669b9767eb86957021f2
PKG_BUILD_DIR:=$(BUILD_DIR)/ripe-atlas-software-probe-$(PKG_VERSION)

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/atlas-sw-probe
  SECTION:=net
  CATEGORY:=Network
  TITLE:=RIPE Atlas software probe
  URL:=https://atlas.ripe.net/about/probes/
  DEPENDS:=+atlas-probe +PACKAGE_dropbear:dropbearconvert
endef

define Package/atlas-sw-probe/description
  RIPE Atlas SW probe is software variant of RIPE Atlas Probe.
  It contains utilities which help actively measure Internet
  connectivity through ping, traceroute, DNS, SSL/TLS, NTP, and HTTP.
  Data are then collected, aggregated and published by the RIPE NCC.
endef

define Package/atlas-sw-probe-rpc
  SECTION:=net
  CATEGORY:=Network
  TITLE:=RPC service
  URL:=https://atlas.ripe.net/about/probes/
  DEPENDS:=+atlas-probe +bind-dig +rpcd
endef

define Package/atlas-sw-probe-rpc/description
  Provides ubus calls for probe.
endef

Build/Compile:=:

define Package/atlas-sw-probe-rpc/postinst
#!/bin/sh
[ -z "$${IPKG_INSTROOT}" ] && /etc/init.d/rpcd restart
exit 0
endef

define Package/atlas-sw-probe-rpc/postrm
#!/bin/sh
[ -z "$${IPKG_INSTROOT}" ] && /etc/init.d/rpcd restart
exit 0
endef

define Package/atlas-sw-probe/conffiles
/etc/atlas/
/etc/config/atlas
endef

TMP_BASE_DIR:=/tmp/ripe_atlas_probe
SCRIPTS_DIR:=/usr/libexec/atlas-probe-scripts
PROBE_BIN_DIR:=/usr/libexec/atlas-probe/bin
PROBE_TYPE:=openwrt-sw-probe

# sed substitutions for .in template files
# Mapping derived from upstream RIPE-NCC/ripe-atlas-software-probe/openwrt/
# autotools configure flags; OpenWrt has no /storage/ split, so the two
# *_sysconfdir variables both resolve to /etc here.
SUBST_SED := \
	-e 's|@probe_scripts_path@|$(PROBE_TYPE)|g' \
	-e 's|@atlas_libexecdir@|$(SCRIPTS_DIR)|g' \
	-e 's|@atlas_scriptsdir@|$(SCRIPTS_DIR)/bin|g' \
	-e 's|@atlas_datadir@|$(SCRIPTS_DIR)|g' \
	-e 's|@atlas_sysconfdir@|/etc/atlas|g' \
	-e 's|@atlas_spooldir@|$(TMP_BASE_DIR)|g' \
	-e 's|@atlas_rundir@|$(TMP_BASE_DIR)|g' \
	-e 's|@atlas_measurementdir@|$(PROBE_BIN_DIR)|g' \
	-e 's|@sysconfdir@|/etc|g' \
	-e 's|@storage_sysconfdir@|/etc|g' \
	-e 's|@tmpdir@|/tmp|g' \
	-e 's|@ripe_atlas_user@|atlas|g' \
	-e 's|@ripe_atlas_group@|atlas|g' \
	-e 's|@ripe_atlas_measurement@|atlas|g' \
	-e 's|@VERSION@|$(PKG_VERSION)|g'

define Build/Prepare
	$(call Build/Prepare/Default,)
	# Generate scripts from .in templates
	$(foreach f, \
		bin/config.sh.in \
		bin/paths.lib.sh.in \
		bin/common-pre.sh.in \
		bin/common.sh.in \
		bin/reginit.sh.in \
		bin/resolvconf.in \
		bin/ripe-atlas.in \
		config/common/FIRMWARE_APPS_VERSION.in, \
		sed $(SUBST_SED) "$(PKG_BUILD_DIR)/$(f)" \
			> "$(PKG_BUILD_DIR)/$(patsubst %.in,%,$(f))"; \
		chmod 755 "$(PKG_BUILD_DIR)/$(patsubst %.in,%,$(f))";)
endef

define Package/atlas-sw-probe/install
	$(INSTALL_DIR) $(1)/$(SCRIPTS_DIR)/bin
	$(INSTALL_DIR) $(1)/$(SCRIPTS_DIR)/bin/arch/$(PROBE_TYPE)
	$(INSTALL_DIR) $(1)/$(SCRIPTS_DIR)/bin/arch/linux
	$(INSTALL_DIR) $(1)/$(SCRIPTS_DIR)/bin/arch/openwrt
	$(INSTALL_DIR) $(1)/$(SCRIPTS_DIR)/etc
	$(INSTALL_DIR) $(1)/$(SCRIPTS_DIR)/state

	# Main ATLAS entry script (generated from ripe-atlas.in, installed as ATLAS)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/ripe-atlas $(1)/$(SCRIPTS_DIR)/bin/ATLAS

	# Generated scripts installed flat in bin/
	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/bin/resolvconf \
		$(PKG_BUILD_DIR)/bin/common-pre.sh \
		$(PKG_BUILD_DIR)/bin/common.sh \
		$(PKG_BUILD_DIR)/bin/config.sh \
		$(PKG_BUILD_DIR)/bin/paths.lib.sh \
		$(PKG_BUILD_DIR)/bin/reginit.sh \
		$(1)/$(SCRIPTS_DIR)/bin/

	# Static library scripts
	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/bin/array.lib.sh \
		$(PKG_BUILD_DIR)/bin/atlas_log.lib.sh \
		$(PKG_BUILD_DIR)/bin/class.lib.sh \
		$(PKG_BUILD_DIR)/bin/json.lib.sh \
		$(PKG_BUILD_DIR)/bin/support.lib.sh \
		$(1)/$(SCRIPTS_DIR)/bin/

	# Arch-specific scripts: install flat in bin/ (used by ripe-atlas/ATLAS entry)
	# and in arch/ subdir (hardcoded by arch reginit/common scripts)
	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/bin/arch/$(PROBE_TYPE)/$(PROBE_TYPE)-ATLAS.sh \
		$(PKG_BUILD_DIR)/bin/arch/$(PROBE_TYPE)/$(PROBE_TYPE)-reginit.sh \
		$(1)/$(SCRIPTS_DIR)/bin/
	$(CP) \
		$(PKG_BUILD_DIR)/bin/arch/$(PROBE_TYPE)/$(PROBE_TYPE)-ATLAS.sh \
		$(PKG_BUILD_DIR)/bin/arch/$(PROBE_TYPE)/$(PROBE_TYPE)-common.sh \
		$(PKG_BUILD_DIR)/bin/arch/$(PROBE_TYPE)/$(PROBE_TYPE)-reginit.sh \
		$(1)/$(SCRIPTS_DIR)/bin/arch/$(PROBE_TYPE)/
	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/bin/arch/linux/linux-functions.sh \
		$(1)/$(SCRIPTS_DIR)/bin/arch/linux/
	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/bin/arch/openwrt/openwrt-common.sh \
		$(1)/$(SCRIPTS_DIR)/bin/arch/openwrt/

	# Config: reg_servers and known_hosts
	$(CP) \
		$(PKG_BUILD_DIR)/config/common/reg_servers.sh.dev \
		$(PKG_BUILD_DIR)/config/common/reg_servers.sh.test \
		$(PKG_BUILD_DIR)/config/probe/known_hosts.reg \
		$(PKG_BUILD_DIR)/config/probe/reg_servers.sh.prod \
		$(1)/$(SCRIPTS_DIR)/etc/

	# State: firmware version, probe mode, initial config
	$(CP) $(PKG_BUILD_DIR)/config/common/FIRMWARE_APPS_VERSION \
		$(1)/$(SCRIPTS_DIR)/state/
	echo "prod" > $(1)/$(SCRIPTS_DIR)/state/mode
	echo "RXTXRPT=yes" > $(1)/$(SCRIPTS_DIR)/state/config.txt

	# Writable runtime dirs as symlinks into /tmp
	$(LN) $(TMP_BASE_DIR)/crons $(1)/$(SCRIPTS_DIR)/crons
	$(LN) $(TMP_BASE_DIR)/data $(1)/$(SCRIPTS_DIR)/data
	$(LN) $(TMP_BASE_DIR)/run $(1)/$(SCRIPTS_DIR)/run
	$(LN) $(TMP_BASE_DIR)/status $(1)/$(SCRIPTS_DIR)/status

	# Sub-architecture config used by reginit
	$(INSTALL_DIR) $(1)/$(SCRIPTS_DIR)/bin/bin
	echo "SUB_ARCH=openwrt-$(ARCH)-$(PKG_VERSION)-$(PKG_RELEASE)" \
		> $(1)/$(SCRIPTS_DIR)/bin/bin/config.sh

	# OpenWrt init, UCI config and readme
	$(INSTALL_DIR) $(1)/etc/init.d/ $(1)/etc/config/ $(1)/etc/atlas/
	$(INSTALL_BIN) ./files/atlas.init $(1)/etc/init.d/atlas
	$(INSTALL_CONF) ./files/atlas.conf $(1)/etc/config/atlas
	$(CP) ./files/atlas.readme $(1)/etc/atlas/
endef

define Package/atlas-sw-probe-rpc/install
	$(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(INSTALL_BIN) ./files/atlas_rpcd.sh $(1)/usr/libexec/rpcd/atlas
endef

$(eval $(call BuildPackage,atlas-sw-probe))
$(eval $(call BuildPackage,atlas-sw-probe-rpc))
