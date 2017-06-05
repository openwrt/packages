#
# Copyright (C) 2008-2012 OpenWrt.org
# Copyright (C) 2017 Willem van den Akker <wvdakker@wilsoft.nl>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shorewall-lite
PKG_VERSION:=5.1.4.1
PKG_DIRECTORY:=5.1
PKG_MAINVERSION:=5.1.4
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.shorewall.net/pub/shorewall/$(PKG_DIRECTORY)/shorewall-$(PKG_MAINVERSION)/ 
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=c06e365d06c484e7ef673e5a8597d70996f1008a00163aae2d7a53d0d720739a8b0317a093b3e75487ef1c8a02ac4c4c542480757226a974671f82ab08353896

PKG_MAINTAINER:=Willem van den Akker <wvdakker@wilsoft.nl>
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/shorewall-lite
    SECTION:=net
    CATEGORY:=Network
    DEPENDS:=+ip +iptables +shorewall-core
    TITLE:=Shorewall Lite
    URL:=http://www.shorewall.net/
    SUBMENU:=Firewall
endef

define Package/shorewall-lite/description
	The Shoreline Firewall, is high-level tool for configuring Netfilter.

	Shorewall allows for central administration of multiple IPv4 firewalls
	through use of Shorewall lite. The full Shorewall product is installed
	on a central administrative system where compiled Shorewall scripts are
	generated. These scripts are copied to the firewall systems where they
	run under the control of Shorewall-lite.

	Note: This is the IPv4 implementation of Shorewall.
endef

define Package/shorewall-lite/conffiles
/etc/shorewall-lite/shorewall-lite.conf
/etc/shorewall-lite/vardir
endef

CONFIGURE_ARGS += \
	vendor=openwrt

define Build/Compile
	DESTDIR=$(PKG_INSTALL_DIR) $(PKG_BUILD_DIR)/install.sh
endef

define Package/shorewall-lite/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/etc/shorewall-lite/state
	$(INSTALL_DIR) $(1)/usr/share
	$(INSTALL_BIN) ./files/hotplug_iface $(1)/etc/hotplug.d/iface/05-shorewall-lite
	$(CP) $(PKG_INSTALL_DIR)/usr/share/shorewall-lite $(1)/usr/share
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/shorewall-lite $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/shorewall-lite/shorecap $(1)/usr/share/shorewall-lite
	$(INSTALL_BIN) ./files/hostname $(1)/usr/share/shorewall-lite
	$(CP) $(PKG_INSTALL_DIR)/etc/shorewall-lite $(1)/etc
	$(CP) $(PKG_INSTALL_DIR)/etc/init.d $(1)/etc
	$(CP) ./files/vardir $(1)/etc/shorewall-lite
endef

$(eval $(call BuildPackage,shorewall-lite))
