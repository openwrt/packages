# Copyright (C) 2016 Cucumber WiFi
#
# This is free software, licensed under the GNU General Public License v2.

include $(TOPDIR)/rules.mk

PKG_NAME:=SocketMan
PKG_VERSION:=170218_9cf1
PKG_MAINTAINER:=Andrew Margarit <andrew@cucumberwifi.io>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/cucumber-tony/SocketMan.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=9cf12667a4c7490795c0cf6177f920c4965e0fd2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MD5SUM=2f1fdf74cbdf04782bd5587fdbacfe47
PKG_HASH=f6e003431375fb40672b7a6f348efa6b2e724d562706422d7ec1c678549f1882

include $(INCLUDE_DIR)/package.mk

MAKE_VARS += CT_ARCH="-D__OPENWRT__"
MAKE_PATH:=src
PKG_BUILD_BIN:=$(PKG_BUILD_DIR)/$(MAKE_PATH)/

define Package/socketman
SECTION:=net
CATEGORY:=Network
DEPENDS:=+zlib +libjson-c +curl +libcurl +libopenssl +libpthread +libmosquitto +libc +libnl
TITLE:=SocketMan communication package for Cucumber Tony
URL:=http://www.cucumberwifi.io
endef

define Package/socketman/description
  SocketMan is used at Cucumber Tony to control any of the OpenWRT access points, 
routers and other devices. It's fully customisable so you can provision against 
your own backend and transmit jobs securely (currently via MQTT).

  The daemon will monitor your network and attempt recovery when necessary. 
It will processes inbound jobs and notify of failures. Finally, it collects 
station data and sends securely to your API.

  Use out of the box with Cucumber Tony or with your own system.
endef

define Package/socketman/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_BIN)/socketman $(1)/usr/bin/socketman
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/socketman.init $(1)/etc/init.d/socketman
endef

$(eval $(call BuildPackage,socketman))
