#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mwan3
PKG_VERSION:=2.0.2
PKG_RELEASE:=1
PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
PKG_LICENSE:=GPLv2

include $(INCLUDE_DIR)/package.mk

define Package/mwan3
   SECTION:=net
   CATEGORY:=Network
   SUBMENU:=Routing and Redirection
   DEPENDS:=+ip +ipset +iptables +iptables-mod-conntrack-extra +iptables-mod-ipopt
   TITLE:=Multiwan hotplug script with connection tracking support
   PKGARCH:=all
endef

define Package/mwan3/description
Hotplug script which makes configuration of multiple WAN interfaces simple
and manageable. With loadbalancing/failover support for up to 250 wan
interfaces, connection tracking and an easy to manage traffic ruleset.
endef

define Package/mwan3/conffiles
/etc/config/mwan3
endef

define Build/Compile
endef

define Package/mwan3/install
$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,mwan3))
