#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=minimalist-pcproxy
PKG_SOURCE_VERSION:=2d6d1b0b0a3b79a9b4a9b0a7606a84600a967bcb
PKG_VERSION:=2015-01-12-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/fingon/minimalist-pcproxy.git
PKG_MAINTAINER:=Markus Stenberg <fingon@iki.fi>
PKG_LICENSE:=GPL-2.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/minimalist-pcproxy
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Lightweight PCP proxy
  URL:=https://github.com/fingon/minimalist-pcproxy
  DEPENDS:=+libubox @IPV6
endef

define Package/minimalist-pcproxy/description
This package contains a daemon which can be used to forward
PCP (Port Control Protocol - RFC6887) requests requests to PCP remote servers.

In and of itself, it is not very useful, but combined with hnetd+miniupnpd
it allows for control of NAT forwarding and firewall pinholes from multiple
hops away.
endef

define Package/minimalist-pcproxy/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/minimalist-pcproxy $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/minimalist-pcproxy.defaults $(1)/etc/uci-defaults/x-minimalist-pcproxy.defaults
endef

define Package/minimalist-pcproxy/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	(. /etc/uci-defaults/x-minimalist-pcproxy.defaults) && rm -f /etc/uci-defaults/x-minimalist-pcproxy.defaults
}
exit 0
endef

$(eval $(call BuildPackage,minimalist-pcproxy))
