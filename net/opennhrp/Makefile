#
# Copyright (C) 2009-2015 OpenWrt.org
# Copyright (C) 2009 Jakob Pfeiffer
# Copyright (C) 2014 Artem Makhutov
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=opennhrp
PKG_VERSION:=0.14.1
PKG_RELEASE:=2
PKG_MAINTAINER:=Artem Makhutov <artem@makhutov.org>
PKG_LICENSE:=MIT License

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/opennhrp
PKG_MD5SUM:=eb42ddb13e07ceb415b9ebb8eaca28ee

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/opennhrp
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  DEPENDS:=+libcares +ipsec-tools +ip +kmod-gre
  KCONFIG:=CONFIG_ARPD=y
  TITLE:=NBMA Next Hop Resolution Protocol
  URL:=http://opennhrp.sourceforge.net/
endef

define Package/opennhrp/description
  OpenNHRP implements NBMA Next Hop Resolution Protocol (as defined in RFC 2332).
  It makes it possible to create dynamic multipoint VPN Linux router using NHRP,
  GRE and IPsec. It aims to be Cisco DMVPN compatible.
endef

define Package/opennhrp/conffiles
/etc/opennhrp/opennhrp.conf
endef

define Package/opennhrp/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/opennhrp{,ctl} $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/opennhrp
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/opennhrp/opennhrp.conf $(1)/etc/opennhrp/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/etc/opennhrp/opennhrp-script $(1)/etc/opennhrp/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/etc/opennhrp/racoon-ph1down.sh $(1)/etc/opennhrp/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/etc/opennhrp/racoon-ph1dead.sh $(1)/etc/opennhrp/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/opennhrp.init $(1)/etc/init.d/opennhrp
endef

$(eval $(call BuildPackage,opennhrp))
