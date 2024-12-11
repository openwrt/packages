#
# Copyright (C) 2017-2018 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tio
PKG_VERSION:=3.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/tio/tio/releases/download/v$(PKG_VERSION)
PKG_HASH:=a24c69e59b53cf72a147db2566b6ff3b6a018579684caa4b16ce36614b2b68d4

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/tio
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Terminal
  TITLE:=A simple TTY terminal I/O application
  URL:=https://tio.github.io/
  DEPENDS:=+lua +glib2
endef

define Package/tio/description
  A small and simple TTY terminal I/O application
endef

define Package/tio/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tio $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,tio))
