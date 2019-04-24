#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ncdu
PKG_VERSION:=1.14
PKG_RELEASE=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://dev.yorhel.nl/download
PKG_HASH:=c694783aab21e27e64baad314b7c1ff34541bfa219fe9645ef6780f1c5558c44

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/ncdu
  SUBMENU:=Filesystem
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libncurses
  TITLE:=ncurses disk usage viewer
  MAINTAINER:=Charles Lehner <celehner1@gmail.com>
  URL:=https://dev.yorhel.nl/ncdu
endef

define Package/ncdu/description
  Ncdu is a ncurses-based du viewer. It provides a fast and easy-to-use
  interface through famous du utility. It allows one to browse through the
  directories and show percentages of disk usage with ncurses library.
endef

CONFIGURE_ARGS += --with-ncurses

define Package/ncdu/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ncdu $(1)/usr/bin/
endef

$(eval $(call BuildPackage,ncdu))
