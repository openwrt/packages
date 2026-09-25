#
# Copyright (C) 2026 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=snmpd-openwrt-metrics
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Kamil Bienkiewicz <perceivalpercy@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/snmpd-openwrt-metrics
  SECTION:=net
  CATEGORY:=Network
  TITLE:=OpenWrt wireless and sensor metrics over SNMP
  URL:=https://openwrt.org
  DEPENDS:=+snmpd +libnetsnmp +libiwinfo +libnl-tiny
endef

define Package/snmpd-openwrt-metrics/description
  An AgentX subagent that exports per-interface wireless metrics under
  OpenWrt's IANA enterprise number 66510 (OPENWRT-WIRELESS-MIB: clients,
  frequency, noise floor, tx/rx rates, SNR, channel utilisation, tx power,
  indexed by ifIndex so the table joins IF-MIB), the device's OpenWrt
  release, build revision, target and model (OPENWRT-MIB), and hwmon
  temperature and fan readings as LM-SENSORS-MIB, which net-snmp cannot
  serve on OpenWrt because its lmSensors module predates the libsensors 3
  API.

  Wireless data comes from libiwinfo, so nothing needs configuring per radio
  or per VAP; a multi-link (MLO) interface's per-link channel/tx power is
  queried directly over nl80211 instead, since libiwinfo has no MLO
  awareness. snmpd enables the AgentX master by default, so no snmpd
  configuration is required either.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include/libnl-tiny \
	-D_GNU_SOURCE

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/snmpd-openwrt-metrics/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt-snmp-agent $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/openwrt-snmp-agent.init $(1)/etc/init.d/openwrt-snmp-agent

	$(INSTALL_DIR) $(1)/usr/share/snmp/mibs
	$(INSTALL_DATA) ./files/OPENWRT-MIB $(1)/usr/share/snmp/mibs/OPENWRT-MIB
	$(INSTALL_DATA) ./files/OPENWRT-WIRELESS-MIB $(1)/usr/share/snmp/mibs/OPENWRT-WIRELESS-MIB
endef

$(eval $(call BuildPackage,snmpd-openwrt-metrics))
