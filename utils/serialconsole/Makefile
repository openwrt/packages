#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sc
PKG_VERSION:=0.95
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/serialconsole/sc
PKG_HASH:=5ae99b370a5a3feb38372b383edc23012b5be5d81547aeb1ac52b408037c1d1c
PKG_MAINTAINER:=Stefan Bethke <stb@lassitu.de>

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/serialconsole
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Terminal
  TITLE:=Serial Console - minimal terminal program
  URL:=http://sourceforge.net/projects/serialconsole/
endef

define Package/serialconsole/description
serialconsole (sc) is a minimal terminal program allowing to use one machine
to access the serial console of another machine.
endef

define Package/serialconsole/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sc $(1)/usr/bin/
endef

$(eval $(call BuildPackage,serialconsole))
