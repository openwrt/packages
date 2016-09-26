#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=evtest
PKG_REV:=ab140a2dab1547f7deb5233be6d94a388cf08b26
PKG_VERSION:=1.33
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=git://anongit.freedesktop.org/evtest
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)

PKG_MAINTAINER:=Pushpal Sidhu <psidhu.devel@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/autotools.mk

define Package/evtest
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Event Test Program
endef

define Package/evtest/description
  Utility to test event driven devices such as keyboards and mice
endef

define Package/evtest/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/evtest $(1)/sbin/
endef

$(eval $(call BuildPackage,evtest))
