# 
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sqm-scripts
PKG_VERSION:=8
PKG_RELEASE:=3
PKG_LICENSE:=GPLv2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/sqm-scripts
  SECTION:=net
  CATEGORY:=Base system
  DEPENDS:=+tc +kmod-sched +kmod-ifb iptables +ip \
	+iptables-mod-ipopt +iptables-mod-conntrack-extra
  TITLE:=SQM Scripts (QoS)
  PKGARCH:=all
  MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
endef

define Package/sqm-scripts/description
 A set of scripts that does simple SQM configuration.
endef

define Package/sqm-scripts/conffiles
/etc/config/sqm
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/sqm-scripts/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/sqm $(1)/etc/init.d/sqm
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/11-sqm $(1)/etc/hotplug.d/iface/11-sqm
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/etc/config/sqm $(1)/etc/config/sqm
	$(INSTALL_DIR) $(1)/usr/lib/sqm
	$(INSTALL_BIN) ./files/usr/lib/sqm/*.sh $(1)/usr/lib/sqm/
	$(INSTALL_BIN) ./files/usr/lib/sqm/*.qos $(1)/usr/lib/sqm/
	$(INSTALL_DATA) ./files/usr/lib/sqm/*.help $(1)/usr/lib/sqm/
endef

$(eval $(call BuildPackage,sqm-scripts))
