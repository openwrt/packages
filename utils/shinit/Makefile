#
# Copyright (C) 2019 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shinit
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0-only
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/shinit
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Initialization for all interactive shells (login or not)
  PKGARCH:=all
endef

define Package/shinit/description
  This package adds support for /etc/shinit and ~/.shinit files, which
  contain commands to be run at the start of all interactive shells.
  (/etc/profile and ~/.profile are read for login shells only.)

  This is useful for those who regularly open non-login, interactive
  shells, for example users of GNU Screen or tmux.
endef

define Package/shinit/conffiles
/etc/shinit
endef

Build/Prepare:=:
Build/Configure:=:
Build/Compile:=:

define Package/shinit/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/etc/shinit $(1)/etc

	$(INSTALL_DIR) $(1)/etc/profile.d
	$(INSTALL_DATA) ./files/etc/profile.d/shinit.sh $(1)/etc/profile.d
endef

$(eval $(call BuildPackage,shinit))
