#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libaio
PKG_VERSION:=0.3.111
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://releases.pagure.org/libaio
PKG_HASH:=62cf871ad8fd09eb3418f00aca7a7d449299b8e1de31c65f28bf6a2ef1fa502a

PKG_MAINTAINER:=Steven Barth <cyrus@openwrt.org>
PKG_LICENSE:=LGPL-2.1-only
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libaio
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Linux kernel AIO interface access library
  URL:=http://lse.sourceforge.net/io/aio.html
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libaio.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libaio.{a,so*} $(1)/usr/lib/
endef

define Package/libaio/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libaio.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libaio))
