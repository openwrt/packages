#
# Copyright (C) 2006-2014 OpenWrt.org
# Copyright (C) 2015 wongsyrone
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mwan3
PKG_VERSION:=2.5
PKG_RELEASE:=5
PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
PKG_LICENSE:=GPLv2

include $(INCLUDE_DIR)/package.mk

define Package/mwan3
   SECTION:=net
   CATEGORY:=Network
   SUBMENU:=Routing and Redirection
   DEPENDS:=+ip +ipset +iptables +iptables-mod-conntrack-extra +iptables-mod-ipopt
   TITLE:=Multiwan hotplug script with connection tracking support
   MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
   PKGARCH:=all
endef

define Package/mwan3/description
Hotplug script which makes configuration of multiple WAN interfaces simple \
and manageable. With loadbalancing/failover support for up to 250 wan \
interfaces, connection tracking and an easy to manage traffic ruleset.
endef

define Package/mwan3/conffiles
/etc/config/mwan3
/etc/mwan3.user
endef

define Build/Compile
endef

define Package/mwan3/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/mwan3.sbin $(1)/usr/sbin/mwan3
	$(INSTALL_BIN) ./files/mwan3track.sbin $(1)/usr/sbin/mwan3track
	$(INSTALL_DIR) $(1)/lib/mwan3
	$(INSTALL_DATA) ./files/mwan3.sh $(1)/lib/mwan3/mwan3.sh
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/mwan3.config $(1)/etc/config/mwan3
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface/
	$(INSTALL_BIN) ./files/mwan3.hotplug $(1)/etc/hotplug.d/iface/15-mwan3
	$(INSTALL_BIN) ./files/mwancustombak.hotplug $(1)/etc/hotplug.d/iface/16-mwancustombak
endef

$(eval $(call BuildPackage,mwan3))

