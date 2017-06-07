#
# Copyright (C) 2008-2012 OpenWrt.org
# Copyright (C) 2017 Willem van den Akker <wvdakker@wilsoft.nl>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shorewall6-lite
PKG_VERSION:=5.1.4.1
PKG_DIRECTORY:=5.1
PKG_MAINVERSION:=5.1.4
PKG_RELEASE:=2

PKG_SOURCE_URL:=http://www.shorewall.net/pub/shorewall/$(PKG_DIRECTORY)/shorewall-$(PKG_MAINVERSION)/ 
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=b616c5886b5bc274e88052359ca4c8aa6df60a9706958698eac7fc362f1c893de00ed2272535d61a88cb6a786bae9b7cba64a835833a9f81c991fb2ffed8244b

PKG_MAINTAINER:=Willem van den Akker <wvdakker@wilsoft.nl>
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING


include $(INCLUDE_DIR)/package.mk

define Package/shorewall6-lite
    SECTION:=net
    CATEGORY:=Network
    DEPENDS:=+ip +ip6tables +shorewall-core
    TITLE:=Shorewall6 Lite
    URL:=http://www.shorewall.net/
    SUBMENU:=Firewall
endef

define Package/shorewall6-lite/description
	The Shoreline Firewall, is high-level tool for configuring Netfilter.

	Shorewall6 allows for central administration of multiple IPv6 firewalls
	through use of Shorewall6 lite. The full Shorewall6 product is installed
	on a central administrative system where compiled Shorewall6 scripts are
	generated. These scripts are copied to the firewall systems where they
	run under the control of Shorewall6-lite.

	Note: This is the IPv6 implementation of Shorewall.
endef

define Package/shorewall6-lite/conffiles
/etc/shorewall6-lite/shorewall6-lite.conf
/etc/shorewall6-lite/vardir
endef

CONFIGURE_ARGS += \
	vendor=openwrt

define Build/Compile
	DESTDIR=$(PKG_INSTALL_DIR) $(PKG_BUILD_DIR)/install.sh
endef

define Package/shorewall6-lite/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/etc/shorewall6-lite/state
	$(INSTALL_DIR) $(1)/usr/share
	$(INSTALL_BIN) ./files/hotplug_iface $(1)/etc/hotplug.d/iface/05-shorewall6-lite
	$(CP) $(PKG_INSTALL_DIR)/usr/share/shorewall6-lite $(1)/usr/share
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/shorewall6-lite $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/shorewall6-lite/shorecap $(1)/usr/share/shorewall6-lite
	$(INSTALL_BIN) ./files/hostname $(1)/usr/share/shorewall6-lite
	$(CP) $(PKG_INSTALL_DIR)/etc/shorewall6-lite $(1)/etc
	$(CP) $(PKG_INSTALL_DIR)/etc/init.d $(1)/etc
	$(CP) ./files/vardir $(1)/etc/shorewall6-lite
endef

$(eval $(call BuildPackage,shorewall6-lite))
