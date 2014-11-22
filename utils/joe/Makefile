#
# Copyright (C) 2007 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# changes by David Kuehling <dvdkhlng TA gmx TOD de>:
#
#  - include support for all emulation modes jmacs jpico etc.
#  - see patches/002-builtinrc.patch

include $(TOPDIR)/rules.mk

PKG_NAME:=joe
PKG_VERSION:=3.7
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/joe-editor
PKG_MD5SUM:=66de1b073e869ba12abbfcde3885c577

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/joe
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libncurses
  TITLE:=JOE - Joes own editor
  URL:=http://sourceforge.net/projects/joe-editor/
  SUBMENU:=Editors
endef

define Package/joe/description
Joe is world-famous Wordstar like text editor, that also features
Emacs and Pico emulation
endef

define Package/joe/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/joe $(1)/usr/bin/
	for i in jmacs jstar rjoe jpico; do \
	  ln -sf joe $(1)/usr/bin/$$$$i; \
	done
endef

$(eval $(call BuildPackage,joe))
