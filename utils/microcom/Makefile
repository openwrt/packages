#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=microcom
PKG_VERSION:=1.06
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/microcom-$(PKG_VERSION)

PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Oliviers-OSS/microcom/archive/
PKG_MD5SUM:=da329a28583cc4f0606179d9abc7f34e
PKG_CAT:=zcat

PKG_LICENSE:=GPL-2.0+

include $(INCLUDE_DIR)/package.mk

define Package/microcom
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Terminal
  TITLE:=Lightweight terminal emulator with scripting support.
  URL:=https://github.com/Oliviers-OSS/microcom
  MAINTAINER:=Geir Pedersen <geir.pedersen+openwrt@gmail.com>
endef

define Package/microcom/Default/description
  Lightweight serial terminal emulator with scripting support.
endef


define Package/microcom/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,microcom))
