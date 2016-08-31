#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tdb
PKG_VERSION:=1.0.6
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/tdb
PKG_MD5SUM:=6b643fdeb48304010dcd5f675e458b58

PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=+libgdbm

include $(INCLUDE_DIR)/package.mk

define Package/tdb
  SUBMENU:=database
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Trivial Database
  URL:=http://sourceforge.net/projects/tdb/
  MAINTAINER:=Dmitry V. Zimin <pfzim@mail.ru>
#  DEPENDS:=+libgdbm
endef

define Package/tdb/description
  TDB is a Trivial Database. In concept, it is very much like GDBM,
  and BSD's DB except that it allows multiple simultaneous writers
  and uses locking internally to keep writers from trampling on
  each other. TDB is also extremely small.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/tdb.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Package/tdb/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,tdb))

