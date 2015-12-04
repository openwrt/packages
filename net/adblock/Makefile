#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=adblock
PKG_VERSION:=0.22.2
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0+
PKG_MAINTAINER:=Dirk Brenken <dirk@brenken.org>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Powerful adblock script to block ad/abuse domains
	DEPENDS:=+curl +wget
	PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
Powerful adblock script to block ad/abuse domains
When the dns server on your router receives dns requests, we will sort out queries that ask for the [A]
resource records of ad servers and return the local ip address of your router and the internal web server
delivers a transparent pixel instead.
The script supports the following domain blacklist sites:
  http://pgl.yoyo.org/adservers
  http://malwaredomains.com
  https://zeustracker.abuse.ch
  https://feodotracker.abuse.ch
  https://palevotracker.abuse.ch
  http://dshield.org
  http://www.shallalist.de
  http://www.spam404.com
  http://winhelp2002.mvps.org

Please read README.md in /etc/adblock for further information.

endef

define Package/$(PKG_NAME)/conffiles
/etc/config/adblock
/etc/adblock/adblock.whitelist
/etc/adblock/adblock.blacklist
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/adblock-update.sh $(1)/usr/bin/
	$(INSTALL_DATA) ./files/adblock-helper.sh $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/adblock.conf $(1)/etc/config/adblock

	$(INSTALL_DIR) $(1)/etc/adblock
	$(INSTALL_CONF) ./files/adblock.blacklist $(1)/etc/adblock/
	$(INSTALL_CONF) ./files/adblock.whitelist $(1)/etc/adblock/
	$(INSTALL_CONF) ./files/README.md $(1)/etc/adblock/

	$(INSTALL_DIR) $(1)/etc/adblock/samples
	$(INSTALL_CONF) ./files/samples/*.sample $(1)/etc/adblock/samples/

	$(INSTALL_DIR) $(1)/www/adblock
	$(INSTALL_DATA) ./files/www/adblock/* $(1)/www/adblock/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
