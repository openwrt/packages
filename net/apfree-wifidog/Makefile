#
# Copyright (C) 2018 Dengfeng Liu
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=apfree-wifidog
PKG_VERSION:=9.05.2872
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/liudf0716/$(PKG_NAME)/tar.gz/$(PKG_VERSION)?
PKG_HASH:=34338d7a7f579225239a2e6ba61e0ddc224471d388284ba2956df29fbb5e6720
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Dengfeng Liu <liudf0716@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/apfree-wifidog
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
	DEPENDS:=+zlib +libjson-c +libevent2 +libevent2-openssl +libuci \
						+openssl-util +libnetfilter-queue +conntrack +libmosquitto \
						+libnftnl +libmnl +libbpf
  TITLE:=Apfree's wireless captive portal solution
  URL:=https://github.com/liudf0716/apfree_wifidog
endef

define Package/apfree-wifidog/description
  The ApFree Wifidog project is a complete and embeddable captive portal
  solution for wireless community groups or individuals who wish to open a free
  Hotspot while still preventing abuse of their Internet connection.
  It's enhanced wifidog
endef

define Package/apfree-wifidog/conffiles
/etc/config/wifidogx
endef

define Package/apfree-wifidog/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/wifidogx $(1)/usr/bin/wifidogx
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/wdctlx $(1)/usr/bin/wdctlx
	$(INSTALL_DIR) $(1)/usr/sbin
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
	$(INSTALL_DIR) $(1)/etc/wifidogx
	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wifi-config $(1)/www/cgi-bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wifi-diag $(1)/www/cgi-bin/
endef

$(eval $(call BuildPackage,apfree-wifidog))
