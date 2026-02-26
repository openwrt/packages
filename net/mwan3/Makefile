#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mwan3
PKG_VERSION:=2.12.0
PKG_RELEASE:=4

PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
PKG_LICENSE:=GPL-2.0
PKG_CONFIG_DEPENDS:=CONFIG_IPV6

include $(INCLUDE_DIR)/package.mk

define Package/mwan3
   SECTION:=net
   CATEGORY:=Network
   SUBMENU:=Routing and Redirection
   DEPENDS:= \
     +ip \
     +ipset \
     +iptables \
     +IPV6:ip6tables \
     +iptables-mod-conntrack-extra \
     +iptables-mod-ipopt \
     +ucode \
     +ucode-mod-fs \
     +ucode-mod-uci \
     +ucode-mod-ubus \
     +ucode-mod-uloop \
     +jshn
   TITLE:=Multiwan hotplug script with connection tracking support
   MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
   PKGARCH:=all
endef

define Package/mwan3/description
Hotplug script which makes configuration of multiple WAN interfaces simple
and manageable. With loadbalancing/failover support for up to 250 wan
interfaces, connection tracking and an easy to manage traffic ruleset.
endef

define Package/mwan3/conffiles
/etc/config/mwan3
/etc/mwan3.user
endef

define Build/Compile
	$(TARGET_CC) $(CFLAGS) $(LDFLAGS) $(FPIC) \
		-shared \
		-o $(PKG_BUILD_DIR)/libwrap_mwan3_sockopt.so.1.0 \
		$(if $(CONFIG_IPV6),-DCONFIG_IPV6) \
		$(PKG_BUILD_DIR)/sockopt_wrap.c \
		-ldl
endef

define Package/mwan3/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/mwan3 \
		$(1)/etc/config/

	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/etc/hotplug.d/iface/15-mwan3 \
		$(1)/etc/hotplug.d/iface/
	$(INSTALL_DATA) ./files/etc/hotplug.d/iface/16-mwan3-user \
		$(1)/etc/hotplug.d/iface/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/mwan3 \
		$(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/lib/mwan3
	$(INSTALL_DATA) ./files/lib/mwan3/common.sh \
		$(1)/lib/mwan3/
	$(INSTALL_DATA) ./files/lib/mwan3/mwan3.sh \
		$(1)/lib/mwan3/

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/usr/sbin/mwan3 \
		$(1)/usr/sbin/
	$(INSTALL_BIN) ./files/usr/sbin/mwan3d \
		$(1)/usr/sbin/
	$(INSTALL_BIN) ./files/usr/sbin/mwan3rtmon \
		$(1)/usr/sbin/
	$(INSTALL_BIN) ./files/usr/sbin/mwan3track \
		$(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) ./files/etc/mwan3.user \
		$(1)/etc/

	$(CP) $(PKG_BUILD_DIR)/libwrap_mwan3_sockopt.so.1.0 $(1)/lib/mwan3/

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/etc/uci-defaults/mwan3-migrate-flush_conntrack \
		$(1)/etc/uci-defaults/
endef

$(eval $(call BuildPackage,mwan3))
