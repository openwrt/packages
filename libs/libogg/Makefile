#
# Copyright (C) 2008-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libogg
PKG_VERSION:=1.3.2
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://downloads.xiph.org/releases/ogg/
PKG_HASH:=3f687ccdd5ac8b52d76328fbbfebc70c459a40ea891dbf3dccb74a210826e79b
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libogg
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libogg
  URL:=http://xiph.org/ogg/
endef

define Package/libogg/description
Ogg project codecs use the Ogg bitstream format to arrange the raw,
compressed bitstream into a more robust, useful form.  For example,
the Ogg bitstream makes seeking, time stamping and error recovery
possible, as well as mixing several sepearate, concurrent media
streams into a single physical bitstream.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/ogg/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/ogg/* $(1)/usr/include/ogg/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{so*,a,la} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
	$(INSTALL_DIR) $(1)/usr/share/aclocal/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/aclocal/* $(1)/usr/share/aclocal/
endef

define Package/libogg/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libogg))
