#
# Copyright (C) 2017-2018 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tio
PKG_VERSION:=2.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/tio/tio/releases/download/v$(PKG_VERSION)
PKG_HASH:=bf8fe434848c2c1b6540af0b42503c986068176ddc1a988cf02e521e7de5daa5

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
  DEPENDS:=+libinih
endef

define Package/tio/description
  A small and simple TTY terminal I/O application
endef

define Package/tio/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tio $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,tio))
