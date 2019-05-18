#
# Copyright (C) 2017 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pcsc-tools
PKG_VERSION=1.5.4
PKG_RELEASE:=1
PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://ludovic.rousseau.free.fr/softwares/pcsc-tools/
PKG_HASH:=c39e6abba781895220c68df5e5d2f0f9547c7a676eebec3f1ddcff8794377c93

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/pcsc-tools
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libpcsclite
  TITLE:=pcsc-tools
  URL:=http://ludovic.rousseau.free.fr/softwares/pcsc-tools/
endef

define Package/pcsc-tools/description
  Tools that are used to test a PC/SC driver, card or reader.
  Only includes pcsc_scan without ATR analysis for now.
endef

define Package/pcsc-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pcsc_scan $(1)/usr/bin
endef

$(eval $(call BuildPackage,pcsc-tools))
