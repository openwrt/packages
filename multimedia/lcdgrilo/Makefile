#
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lcdgrilo
PKG_VERSION:=0.0.13
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.flyn.org/projects/lcdgrilo
PKG_HASH:=844ecd404986f1a998bd0992341a329913ab981a1fd94172537ca9aa25769b15

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=vala/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/lcdgrilo
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+grilo +grilo-plugins +gstreamer1-libs +libgee +libgstreamer1
  TITLE:=lcdgrilo
  URL:=https://www.flyn.org/projects/lcdgrilo/
endef

define Package/lcdgrilo/description
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
