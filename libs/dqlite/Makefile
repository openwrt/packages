#
# Copyright (C) 2019 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dqlite
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/CanonicalLtd/dqlite
PKG_SOURCE_VERSION:=34933279886ec8fbad4e22d78a7ec6d79950d5f7

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/autotools.mk

define Package/dqlite
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for distributed SQLite for Go applications
  DEPENDS:= +libuv +libsqlite3
endef

define Package/dqlite/description
  This repository provides the dqlite C library (libdqlite), which can be used
  to expose a SQLite database over the network and replicate it across a cluster
  of peers, using the Raft algorithm.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/dqlite.h $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdqlite.{a,so*} $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/dqlite.pc $(1)/usr/lib/pkgconfig/
endef

define Package/dqlite/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,dqlite))
