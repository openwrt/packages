#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sstp-client
PKG_VERSION:=1.0.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/sstp-client/$(PKG_VERSION)
PKG_MD5SUM:=40f1d1b1596b4f1817ec903f58b2780c
PKG_LICENSE=GPLv2

include $(INCLUDE_DIR)/package.mk

define Package/sstp-client
  SECTION:=net
  CATEGORY:=Network
  DEPENDS=+libevent2 +libopenssl +ppp
  TITLE:=SSTP is Microsofts Remote Access Solution for PPP over SSL
  URL:=http://sstp-client.sourceforge.net/
  MAINTAINER:=Federico Di Marco <fededim@gmail.com>
endef

define Package/sstp-client/description
 It can be used instead of PPTP or L2TP, and is only available with Windows Vista/7 connecting to a Windows 2008 Server. The advantage of SSTP  compared to PPTP and L2TP is that it cannot be easily blocked by firewalls since the traffic is transmitted over HTTPS on port 443.
 Windows Vista/7 uses SSTP whenever PPTP or L2TP cannot be established. For further information on SSTP check out wikipedia's article on Secure Socket Tunneling Protocol.
endef

define Package/sstp-client/conffiles
	/etc/ppp/chap-secrets
	/etc/ppp/peers/peer-sstp-example-nopty.txt
	/etc/ppp/peers/peer-sstp-example.txt
endef

define Package/sstp-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/.libs/sstpc $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/libsstp-api/.libs/*.so* $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/src/pppd-plugin/.libs/*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/ppp
	$(INSTALL_DIR) $(1)/etc/peers
endef

$(eval $(call BuildPackage,sstp-client))
