#
# Copyright (C) 2011-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmpdclient
PKG_VERSION:=2.7
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.musicpd.org/download/libmpdclient/2/
PKG_MD5SUM:=053a97f1b045646d2d01a68fb2ddb5ef
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libmpdclient
    TITLE:=libmpdclient
    SECTION:=libs
    CATEGORY:=Libraries
    URL:=http://mpd.wikia.com/wiki/ClientLib:libmpdclient
    DEPENDS:=
endef

define Package/libmpdclient/description
    A stable, documented, asynchronous API library for interfacing MPD in the C, C++ & Objective C languages.
endef

TARGET_CFLAGS+="-std=gnu99"

#TARGET_LDFLAGS+=-lpthread

define Build/Configure
	$(call Build/Configure/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) \
		$(1)/usr/include \
		$(1)/usr/lib \
		$(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/* \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/* \
		$(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig \
		$(1)/usr/lib/
endef

define Package/libmpdclient/install
	$(INSTALL_DIR) \
		$(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libmpdclient.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libmpdclient))
