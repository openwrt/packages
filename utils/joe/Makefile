#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# changes by David Kuehling <dvdkhlng TA gmx TOD de>:
#
#  - include support for all emulation modes jmacs jpico etc.
#  - see patches/002-builtinrc.patch
#
# changes by Vitaly Prosko <villy TA sft TOD ru>:
#
#  - updated for new build system rules
#  - added static joerc config - no more defaults for native mode
#  - got maintenance role
#

include $(TOPDIR)/rules.mk

PKG_NAME:=joe
PKG_VERSION:=4.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/joe-editor
PKG_HASH:=495a0a61f26404070fe8a719d80406dc7f337623788e445b92a9f6de512ab9de

PKG_MAINTAINER:=Vitaly Protsko <villy@sft.ru>
PKG_LICENCE:=GPL-2.0
PKG_CPE_ID:=cpe:/a:joseph_allen:joe

include $(INCLUDE_DIR)/package.mk

define Package/joe
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Editors
  TITLE:=JOE - Joes own editor
  URL:=https://sourceforge.net/projects/joe-editor/
  DEPENDS:=+libncurses
endef

define Package/joe/description
Joe is world-famous Wordstar like text editor, that also features
Emacs and Pico emulation
endef

define Package/joe/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/joe/joe $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/joe
	$(INSTALL_CONF) ./files/joerc $(1)/etc/joe/joerc
endef

define Package/joe/conffiles
/etc/joe/joerc
endef

$(eval $(call BuildPackage,joe))
