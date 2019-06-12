#
# Copyright (C) 2018 KunTeng.org.cn
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wifidogx
PKG_VERSION:=3.11.1716
PKG_RELEASE=1


PKG_LICENSE:=GPL-3.0
PKG_MAINTAINER:=Dengfeng Liu<liudengfeng@kunteng.org>
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/liudf0716/apfree_wifidog.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=01dfcb80ddaacc0ec234335ff1c229c9af2524b6b802216de93bcc85588a823e

PKG_INSTALL:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/$(PKG_NAME)
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+zlib +iptables-mod-extra +iptables-mod-ipopt +kmod-ipt-nat +iptables-mod-nat-extra \
           +libpthread +libopenssl +@OPENSSL_WITH_EC +@OPENSSL_WITH_DEPRECATED +@OPENSSL_WITH_PSK \
           +libjson-c +ipset +libip4tc +libevent2 +libevent2-openssl \
           +fping +libmosquitto +libuci +px5g
  TITLE:=A wireless captive portal solution

endef

define Package/$(PKG_NAME)/description
	portal solution for wireless community groups or individuals
	who wish to open a free Hotspot while still preventing abuse
	of their Internet connection.
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/wifidogx $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/wdctlx $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/wdping $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/wifidog-msg.html $(1)/etc/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/wifidog-redir.html $(1)/etc/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/wifidog-redir.html.front $(1)/etc/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/wifidog-redir.html.rear $(1)/etc/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/authserver-offline.html $(1)/etc/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/internet-offline.html $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/wifidogx.init $(1)/etc/init.d/wifidogx
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/wifidogx.conf $(1)/etc/config/wifidogx
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
