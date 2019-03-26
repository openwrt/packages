#
# Copyright (C) 2017 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pcsc-tools
PKG_VERSION=1.5.3
PKG_RELEASE:=1
PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://ludovic.rousseau.free.fr/softwares/pcsc-tools/
PKG_HASH:=daaa011c28daa00653bd8e2a3d8b0b9f8abae00f7344f50b1a94fbd2b01f1d14

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
