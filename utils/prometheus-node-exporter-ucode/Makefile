# Copyright (C) 2013-2017 OpenWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=prometheus-node-exporter-ucode
PKG_VERSION:=2025.12.04
PKG_RELEASE:=1

PKG_MAINTAINER:=Andre Heider <a.heider@gmail.com>
PKG_LICENSE:=Apache-2.0

include $(INCLUDE_DIR)/package.mk

Build/Compile=

define Package/$(PKG_NAME)/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Prometheus node exporter
  PKGARCH:=all
endef

define Package/$(PKG_NAME)
  $(call Package/$(PKG_NAME)/Default)
  DEPENDS:=+uhttpd +uhttpd-mod-ucode +rpcd +ucode-mod-fs +ucode-mod-ubus
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/config $(1)/etc/config/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/init $(1)/etc/init.d/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/usr/share/ucode/node-exporter/lib
	$(INSTALL_DATA) ./files/metrics.uc $(1)/usr/share/ucode/node-exporter/
	$(INSTALL_DATA) ./files/base/*.uc $(1)/usr/share/ucode/node-exporter/lib/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/run.sh $(1)/usr/bin/$(PKG_NAME)
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/$(PKG_NAME)
endef

define Package/$(PKG_NAME)/description
  Provides node metrics as Prometheus scraping endpoint.

  This service is a lightweight rewrite in ucode of the official Prometheus node_exporter.
endef

$(eval $(call BuildPackage,prometheus-node-exporter-ucode))

define Collector
  define Package/$(PKG_NAME)-$(1)
    $$(call Package/$(PKG_NAME)/Default)
    TITLE+= ($(2))
    DEPENDS:=$(PKG_NAME) $(3)
  endef

  define Package/$(PKG_NAME)-$(1)/install
	$$(INSTALL_DIR) $$(1)/usr/share/ucode/node-exporter/lib
	$$(INSTALL_DATA) ./files/extra/$(1).uc $$(1)/usr/share/ucode/node-exporter/lib/
  endef

  $$(eval $$(call BuildPackage,$(PKG_NAME)-$(1)))
endef

$(eval $(call Collector,dnsmasq,Dnsmasq collector,@dnsmasq))
$(eval $(call Collector,hwmon,hwmon collector,))
$(eval $(call Collector,ltq-dsl,Lantiq/Intel/MaxLinear DSL collector,@ltq-dsl-app))
$(eval $(call Collector,netstat,netstat collector,))
$(eval $(call Collector,odhcp6c,odhcp6c statistics collector,@odhcp6c))
$(eval $(call Collector,openwrt,OpenWrt collector,))
$(eval $(call Collector,realtek-poe,RealTek PoE collector,@realtek-poe))
$(eval $(call Collector,snmp6,snmp6 collector,))
$(eval $(call Collector,thermal,thermal collector,))
$(eval $(call Collector,uci_dhcp_host,UCI DHCP host collector,))
$(eval $(call Collector,wifi,Wi-Fi collector,+ucode-mod-nl80211))
$(eval $(call Collector,wireguard,Wireguard collector,+rpcd-mod-wireguard))
