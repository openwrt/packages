#
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lcdgrilo
PKG_VERSION:=0.0.10
PKG_RELEASE:=1

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.flyn.org/projects/lcdgrilo
PKG_MD5SUM:=37b0b6519968c2949eae4abfc9030325
PKG_BUILD_DEPENDS:=+vala

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/lcdgrilo
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+grilo +grilo-plugins +libgee +libgstreamer1
  TITLE:=lcdgrilo
  URL:=http://www.flyn.org/projects/lcdgrilo/
endef

define Package/lcdgrilo/decription
	A simple Grilo-based audio player meant to run on a Raspberry Pi with a PiFace CAD
endef

define Package/lcdgrilo/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/lcdgrilo \
		$(1)/usr/bin/
	$(INSTALL_BIN) ./files/lcdgrilo.init $(1)/etc/init.d/lcdgrilo
endef

$(eval $(call BuildPackage,lcdgrilo))
