#
# Copyright (C) 2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=freeradius-client
PKG_VERSION:=1.1.7
PKG_RELEASE:=1

PKG_SOURCE:=freeradius-client-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=ftp://ftp.freeradius.org/pub/freeradius/
PKG_MD5SUM:=43b4d21715b613dc4fe8ef128467fe78

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/freeradius-client
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A library for radius clients
  URL:=http://freeradius.org/freeradius-client/
  MAINTAINER:=Nikos Mavrogiannopoulos <nmav@gnutls.org>
endef

define Package/freeradius-client/decription
  FreeRADIUS Client is a framework and library for writing RADIUS
  Clients. The library lets you develop a RADIUS-aware application
  in less than 50 lines of C code. It is highly portable and runs on
  Linux, many BSD variants and Solaris.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/freeradius-client.h \
		$(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libfreeradius-client.{a,so*} \
		$(1)/usr/lib/
endef

define Package/freeradius-client/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libfreeradius-client.so.* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,freeradius-client))
