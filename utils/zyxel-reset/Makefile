#
# Copyright (C) 2022 David Bauer <mail@david-bauer.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zyxel-reset
PKG_SOURCE_DATE:=2022-12-23
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/blocktrron/zyxel-reset.git
PKG_SOURCE_VERSION:=e1def7b5f117c206afe15aa57ca7433eb972d5d1
PKG_MIRROR_HASH:=dc02f6afc5d083a7a62ec51b35b352595ef6c99a8192facb1bff7b7f90cec06a

PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/zyxel-reset
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Trigger factory-reset for ZyXEL APs
endef

define Package/zyxel-reset/description
	This program can trigger a factory-reset on ZyXEL Access Points
	running stock-firmware.
endef

define Package/zyxel-reset/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/zyxel-reset $(1)/usr/bin/zyxel-reset
endef

$(eval $(call BuildPackage,zyxel-reset))
