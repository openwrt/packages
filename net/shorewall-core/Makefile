#
# Copyright (C) 2008-2012 OpenWrt.org
# Copyright (C) 2017 Willem van den Akker <wvdakker@wilsoft.nl>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shorewall-core
PKG_VERSION:=5.1.4.1
PKG_DIRECTORY:=5.1
PKG_RELEASE:=1
PKG_MAINVERSION:=5.1.4

PKG_SOURCE_URL:=http://www.shorewall.net/pub/shorewall/$(PKG_DIRECTORY)/shorewall-$(PKG_MAINVERSION)/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=3d1446f7e437104c8f8c7257ccdbddfc0dc7df3ea68b80274c11dd94cc1c8629

PKG_MAINTAINER:=Willem van den Akker <wvdakker@wilsoft.nl>
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/shorewall-core
    SECTION:=net
    CATEGORY:=Network
    DEPENDS:=+ip +iptables
    TITLE:=Shorewall Core
    URL:=http://www.shorewall.net/
    SUBMENU:=Firewall
endef

define Package/shorewall-core/description
	The Shoreline Firewall, is high-level tool for configuring Netfilter.
	This package provides the core Shorewall libraries installed in /usr/share/shorewall/,
	which are required for the rest of the Shorewall packages to work.
endef

define Package/shorewall-core/conffiles
	/usr/share/shorewall/shorewallrc
endef

CONFIGURE_ARGS += \
	vendor=openwrt

define Build/Compile
	DESTDIR=$(PKG_INSTALL_DIR) $(PKG_BUILD_DIR)/install.sh
endef

define Package/shorewall-core/install
	$(INSTALL_DIR) $(1)/usr/share
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/share/shorewall $(1)/usr/share
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/shorewall/wait4ifup $(1)/usr/share/shorewall
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/shorewall $(1)/usr/sbin
endef

$(eval $(call BuildPackage,shorewall-core))
