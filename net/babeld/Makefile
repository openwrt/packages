# SPDX-License-Identifier: GPL-2.0-or-later
#
# Copyright (C) 2007-2021 OpenWrt.org
#

include $(TOPDIR)/rules.mk

PKG_NAME:=babeld
PKG_VERSION:=1.13.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.irif.fr/~jch/software/files/
PKG_HASH:=15f24d26da0ccfc073abcdef0309f281e4684f2aa71126f826572c4c845e8dd9

PKG_MAINTAINER:=Gabriel Kerneis <gabriel@kerneis.info>, \
	Baptiste Jonglez <openwrt-pkg@bitsofnetworks.org>, \
	Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENCE

include $(INCLUDE_DIR)/package.mk

define Package/babeld
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=A loop-avoiding distance-vector routing protocol
  URL:=https://www.irif.fr/~jch/software/babel/
  DEPENDS:=@IPV6 +libubus +libubox
endef

define Package/babeld/description
  Babel is a loop-avoiding distance-vector routing protocol for IPv6 and IPv4
  with fast convergence properties. It is based on the ideas in DSDV, AODV and
  Cisco's EIGRP, but is designed to work well not only in wired networks but
  also in wireless mesh networks, and has been extended with support for
  overlay networks. Babel is an IETF standard protocol (RFC 8966).
endef

define Package/babeld/conffiles
/etc/babeld.conf
/etc/config/babeld
endef

MAKE_FLAGS+= \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDLIBS="-lubus -lubox"

define Package/babeld/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/babeld $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/babeld.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/babeld.config $(1)/etc/config/babeld
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/babeld.init $(1)/etc/init.d/babeld
endef

$(eval $(call BuildPackage,babeld))
