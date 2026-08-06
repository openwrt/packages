# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2009-2017 OpenWrt.org
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bird2
PKG_VERSION:=2.19.2
PKG_RELEASE:=2

PKG_SOURCE:=bird-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://bird.nic.cz/download/
PKG_HASH:=aff89abba3b92b7637bd57e0168b8d7ae887747f160ada4973378ad72f5f3660

PKG_MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=README
PKG_CPE_ID:=cpe:/a:nic:bird

PKG_BUILD_DEPENDS:=ncurses readline
PKG_BUILD_DIR:=$(BUILD_DIR)/bird-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/bird2
  TITLE:=The BIRD Internet Routing Daemon (v2)
  URL:=https://bird.nic.cz/
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  DEPENDS:=+libpthread
  CONFLICTS:=bird1-ipv4 bird1-ipv6 bird4 bird6
endef

define Package/bird2c
  TITLE:=The BIRD command-line client (v2)
  URL:=https://bird.nic.cz/
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  DEPENDS:=+bird2 +libreadline +libncurses
  CONFLICTS:=bird1c-ipv4 bird1c-ipv6 birdc4 birdc6
endef

define Package/bird2cl
  TITLE:=The BIRD lightweight command-line client (v2)
  URL:=https://bird.nic.cz/
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  DEPENDS:=+bird2
  CONFLICTS:=bird1cl-ipv4 bird1cl-ipv6 birdcl4 birdcl6
endef

define Package/bird2/Default/description
  BIRD is an internet routing daemon which manages TCP/IP routing tables
  with support of modern routing protocols, easy to use configuration
  interface and powerful route filtering language. It is lightweight and
  efficient and therefore appropriate for small embedded routers.
endef

define Package/bird2/description
  $(call Package/bird2/Default/description)

  BIRD supports OSPFv2, RIPv2, Babel and BGP protocols for IPv4 and
  OSPFv3, RIPng, Babel and BGP protocols for IPv6.

  In BGP, BIRD supports communities, multiprotocol extensions, MD5
  authentication, 32bit AS numbers and could act as a route server or a
  route reflector. BIRD also supports multiple RIBs, multiple kernel
  routing tables and redistribution between the protocols with a powerful
  configuration syntax.

  This is the 2.0 branch of Bird which integrates support for IPv4 and IPv6
  into a single branch, and also adds support for the Babel routing protocol.
endef

define Package/bird2c/description
  $(call Package/bird2/Default/description)

  This is a BIRD command-line client. It is used to send commands to BIRD,
  commands can perform simple actions such as enabling/disabling of
  protocols, telling BIRD to show various information, telling it to show
  a routing table filtered by a filter, or asking BIRD to reconfigure.

  Unless you can't afford dependency on ncurses and readline, you
  should install BIRD command-line client together with BIRD.
endef

define Package/bird2cl/description
  $(call Package/bird2/Default/description)

  This is a BIRD lightweight command-line client. It is used to send commands
  to BIRD, commands can perform simple actions such as enabling/disabling of
  protocols, telling BIRD to show various information, telling it to show
  a routing table filtered by a filter, or asking BIRD to reconfigure.
endef

CONFIGURE_ARGS += --disable-libssh

define Package/bird2/conffiles
/etc/bird.conf
endef

define Package/bird2/install
	$(INSTALL_DIR)  $(1)/usr/sbin
	$(INSTALL_BIN)  $(PKG_BUILD_DIR)/bird $(1)/usr/sbin/
	$(INSTALL_DIR)  $(1)/etc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/doc/bird.conf.example $(1)/etc/bird.conf
	$(INSTALL_DIR)  $(1)/etc/init.d
	$(INSTALL_BIN)  ./files/bird.init $(1)/etc/init.d/bird
endef

define Package/bird2c/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/birdc $(1)/usr/sbin/
endef

define Package/bird2cl/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/birdcl $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,bird2))
$(eval $(call BuildPackage,bird2c))
$(eval $(call BuildPackage,bird2cl))
