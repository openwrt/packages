#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=evtest
PKG_VERSION:=1.35
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://gitlab.freedesktop.org/libevdev/evtest
PKG_MIRROR_HASH:=0a2599d92a6915ecedf43c341917fb6f332ffd3967352a2458acf5290167813e

PKG_MAINTAINER:=Pushpal Sidhu <psidhu.devel@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/evtest
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Event Test Program
  URL:=https://gitlab.freedesktop.org/libevdev/evtest
endef

define Package/evtest/description
  Utility to test event driven devices such as keyboards and mice
endef

define Package/evtest/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/evtest $(1)/sbin/
endef

$(eval $(call BuildPackage,evtest))
