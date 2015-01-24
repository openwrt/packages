#
# Copyright (C) 2013-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=xupnpd
PKG_REV:=404
PKG_VERSION:=$(PKG_REV)
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=svn
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=xupnpd-$(PKG_VERSION)
PKG_SOURCE_URL:=http://tsdemuxer.googlecode.com/svn/trunk/xupnpd/src/
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

include $(INCLUDE_DIR)/package.mk

LUA_FLAGS:=-llua

define Build/Compile
	(cd $(PKG_BUILD_DIR); $(TARGET_CC) -v $(LUA_FLAGS) $(TARGET_CFLAGS) -fno-exceptions -fno-rtti -DWITH_URANDOM $(TARGET_CPPFLAGS) $(TARGET_LDFLAGS) -lm -ldl -lcrypt -o xupnpd *.c *.cpp)
endef

define Package/xupnpd
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+liblua
  TITLE:=eXtensible UPnP agent
  URL:=http://xupnpd.org/
endef

define Package/xupnpd/conffiles
/usr/share/xupnpd/xupnpd.lua
/usr/share/xupnpd/config
/usr/share/xupnpd/playlists
endef

define Package/xupnpd/description
xupnpd - eXtensible UPnP agent
This program is a light DLNA Media Server which provides ContentDirectory:1 service for sharing IPTV unicast streams over local area network (with udpxy for multicast to HTTP unicast conversion).
The program shares UTF8-encoded M3U playlists with links over local area network as content of the directory.
You can watch HDTV broadcasts (multicast or unicast) and listen Internet Radio in IP network without transcoding and PC.
endef

define Package/xupnpd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/xupnpd $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/xupnpd.init $(1)/etc/init.d/xupnpd
	$(INSTALL_DIR) $(1)/usr/share/xupnpd
	$(CP) $(PKG_BUILD_DIR)/*.lua $(1)/usr/share/xupnpd
	$(INSTALL_DIR) $(1)/usr/share/xupnpd/ui
	$(CP) $(PKG_BUILD_DIR)/ui/* $(1)/usr/share/xupnpd/ui
	$(INSTALL_DIR) $(1)/usr/share/xupnpd/www
	$(CP) $(PKG_BUILD_DIR)/www/* $(1)/usr/share/xupnpd/www
	$(INSTALL_DIR) $(1)/usr/share/xupnpd/playlists
	$(INSTALL_DIR) $(1)/usr/share/xupnpd/plugins
	$(CP) $(PKG_BUILD_DIR)/plugins/* $(1)/usr/share/xupnpd/plugins
	$(INSTALL_DIR) $(1)/usr/share/xupnpd/config
	$(INSTALL_DIR) $(1)/etc/xupnpd
	(cd $(1)/etc/xupnpd; ln -s ../../usr/share/xupnpd/config ./; ln -s ../../usr/share/xupnpd/xupnpd.lua ./)
	$(INSTALL_DIR) $(1)/usr/share/xupnpd/localmedia
endef

$(eval $(call BuildPackage,xupnpd))
