#
# Copyright (C) 2018-2019 Luiz Angelo Daros de Luca
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=trafficshaper
PKG_VERSION:=1.0.0
PKG_RELEASE:=5
PKG_MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>

PKG_LICENSE:=GPL-2.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/trafficshaper/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=WAN traffic shaper based on LAN addresses
  DEPENDS:=+tc +kmod-sched-core +kmod-sched-connmark +kmod-ifb \
	+kmod-sched-cake
  PROVIDES:=trafficshaper
  PKGARCH:=all
endef

define Package/trafficshaper
  $(call Package/trafficshaper/Default)
  TITLE+= (nftables)
  DEPENDS+= +nftables
  VARIANT:=nftables
  DEFAULT_VARIANT:=1
endef

define Package/trafficshaper-iptables
  $(call Package/trafficshaper/Default)
  TITLE+= (iptables)
  DEPENDS+= +iptables +IPV6:ip6tables +iptables-mod-conntrack-extra
  VARIANT:=iptables
  CONFLICTS:=trafficshaper
endef

define Package/trafficshaper/description
  Setup QoS rules to limit (or reserve) traffic used by classes of clients.
  Uplink and downlink can be controlled (or not controlled) independently.
  Client classes are defined by its network addresses (IPv4 or IPv6). Each
  client class can define absolute or relative (to wan) bandwidth, and also
  the use (or not) of spare wan bandwidth when available.
endef

define Package/trafficshaper-iptables/description
  $(call Package/trafficshaper/description)
endef

define Package/trafficshaper/conffiles
/etc/config/trafficshaper
endef

Package/trafficshaper-iptables/conffiles = $(Package/trafficshaper/conffiles)

define Build/Compile
endef

define Package/trafficshaper/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/trafficshaper.conf $(1)/etc/config/trafficshaper
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/trafficshaper.init $(1)/etc/init.d/trafficshaper
endef

Package/trafficshaper-iptables/install = $(Package/trafficshaper/install)

$(eval $(call BuildPackage,trafficshaper))
$(eval $(call BuildPackage,trafficshaper-iptables))
