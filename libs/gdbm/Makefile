#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gdbm
PKG_VERSION:=1.11
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/gdbm
PKG_MD5SUM:=72c832680cf0999caedbe5b265c8c1bd

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

PKG_FIXUP:=autoreconf gettext-version
PKG_REMOVE_FILES:=Makefile compat/Makefile doc/Makefile export/Makefile src/Makefile tests/Makefile
PKG_BUILD_PARALLEL:=0

PKG_BUILD_DEPENDS:=gettext-full/host

include $(INCLUDE_DIR)/package.mk

define Package/libgdbm
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GNU database manager
  URL:=http://www.gnu.org/software/gdbm/
endef

define Package/libgdbm/description
  GNU database manager library
  GNU dbm is a set of database routines that use extendible hashing and
  works similar to the standard UNIX dbm routines.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		BINOWN=`id -u` \
		BINGRP=`id -g` \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gdbm.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgdbm.{a,so*} $(1)/usr/lib/
endef

define Package/libgdbm/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgdbm.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libgdbm))
