#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=addrwatch
PKG_VERSION:=0.8
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-master.tar.gz
PKG_SOURCE_URL:=https://github.com/fln/addrwatch/releases/download/$(PKG_VERSION)/
PKG_HASH:=0455bd8d2e18a793e1182712bf4df3e54a5b7575f82f5b79b60deef19ff93df8
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-master
PKG_FIXUP:=autoreconf
PKG_BUILD_DEPENDS:=USE_UCLIBC:argp-standalone USE_MUSL:argp-standalone

include $(INCLUDE_DIR)/package.mk

define Package/addrwatch
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpcap +libevent2
  TITLE:=IPv4/IPv6 and ethernet address pairing tool
  URL:=https://github.com/fln/addrwatch
  MAINTAINER:=Ondrej Caletka <ondrej@caletka.cz>
endef

define Package/addrwatch/description
  This is a tool similar to arpwatch. It main purpose is to monitor network and 
  log discovered ethernet/ip pairings. Addrwatch is extremely useful in networks
  with IPv6 autoconfiguration (RFC4862) enabled. It allows to track IPv6
  addresses of hosts using IPv6 privacy extensions (RFC4941).
endef

define Package/addrwatch/conffiles
	/etc/config/addrwatch
endef

define Package/addrwatch/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/addrwatch $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/addrwatch.init $(1)/etc/init.d/addrwatch
	$(INSTALL_CONF) ./files/addrwatch.config $(1)/etc/config/addrwatch
endef

$(eval $(call BuildPackage,addrwatch))
