#
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lcdringer
PKG_VERSION:=0.0.2
PKG_RELEASE:=1

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.flyn.org/projects/lcdringer
PKG_MD5SUM:=ff3fe82593792c9111f957dd533369fb
PKG_BUILD_DEPENDS:=+vala

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/lcdringer
  SECTION:=network
  CATEGORY:=Network
  DEPENDS:=+libgee +libgstreamer1 +loudmouth @TARGET_brcm2708
  TITLE:=lcdringer
  URL:=http://www.flyn.org/projects/lcdringer/
endef

define Package/lcdringer/decription
	A simple Jabber-initiated ringer meant to run on a Raspberry Pi with a PiFace CAD
endef

define Package/lcdringer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/lcdringer \
		$(1)/usr/bin/
	$(INSTALL_BIN) ./files/lcdringer.init $(1)/etc/init.d/lcdringer
	$(INSTALL_DIR) $(1)/usr/share/lcdringer
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/share/lcdringer/* \
		$(1)/usr/share/lcdringer
endef

$(eval $(call BuildPackage,lcdringer))
