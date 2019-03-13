# 
# Copyright (C) 2009-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=bird1
PKG_VERSION:=1.6.6
PKG_RELEASE:=1

PKG_SOURCE:=bird-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=ftp://bird.network.cz/pub/bird
PKG_HASH:=975b3b7aefbe1e0dc9c11e55517f0ca2d82cca1d544e2e926f78bc843aaf2d70
PKG_BUILD_DEPENDS:=ncurses readline
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>
PKG_BUILD_DIR:=$(BUILD_DIR)/bird-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/bird1/Default
  TITLE:=The BIRD Internet Routing Daemon (v1.6)
  URL:=https://bird.network.cz/
  DEPENDS:=+libpthread
endef

define Package/bird1c/Default
  TITLE:=The BIRD command-line client (v1.6)
  URL:=https://bird.network.cz/
  DEPENDS:=+libreadline +libncurses
endef

define Package/bird1cl/Default
  TITLE:=The BIRD lightweight command-line client (v1.6)
  URL:=https://bird.network.cz/
endef

define Package/bird1/Default/description1
BIRD is an internet routing daemon which manages TCP/IP routing tables
with support of modern routing protocols, easy to use configuration
interface and powerful route filtering language. It is lightweight and
efficient and therefore appropriate for small embedded routers.

This packages the legacy v1.6 branch of Bird, which splits IPv4 and IPv6
support into separate binaries. See also the bird2 package for the newer
branch which integrates support for both IP protocols in a single binary.

endef

define Package/bird1/Default/description2
In BGP, BIRD supports communities, multiprotocol extensions, MD5
authentication, 32bit AS numbers and could act as a route server or a
route reflector. BIRD also supports multiple RIBs, multiple kernel
routing tables and redistribution between the protocols with a powerful
configuration syntax.

endef

define Package/bird1/Default/description3
This is a BIRD command-line client. It is used to send commands to BIRD,
commands can perform simple actions such as enabling/disabling of
protocols, telling BIRD to show various information, telling it to show
a routing table filtered by a filter, or asking BIRD to reconfigure.

Unless you can't afford dependency on ncurses and readline, you
should install BIRD command-line client together with BIRD.

endef

define Package/bird1/Default/description4
This is a BIRD lightweight command-line client. It is used to send commands to BIRD,
commands can perform simple actions such as enabling/disabling of
protocols, telling BIRD to show various information, telling it to show
a routing table filtered by a filter, or asking BIRD to reconfigure.

endef

define Package/bird1-ipv4
$(call Package/bird1/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE+= (IPv4)
  CONFLICTS+=bird4
endef

define Package/bird1c-ipv4
$(call Package/bird1c/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE+= (IPv4)
  DEPENDS+=+bird1-ipv4
  CONFLICTS+=birdc4
endef

define Package/bird1cl-ipv4
$(call Package/bird1cl/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE+= (IPv4)
  DEPENDS+=+bird1-ipv4
  CONFLICTS+=birdcl4
endef

define Package/bird1-ipv6
$(call Package/bird1/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE+= (IPv6)
  CONFLICTS+=bird6
endef

define Package/bird1c-ipv6
$(call Package/bird1c/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE+= (IPv6)
  DEPENDS+=+bird1-ipv6
  CONFLICTS+=birdc6
endef

define Package/bird1cl-ipv6
$(call Package/bird1cl/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE+= (IPv6)
  DEPENDS+=+bird1-ipv6
  CONFLICTS+=birdcl6
endef

define Package/bird1-ipv4/description
$(call Package/bird1/Default/description1)
This is IPv4 version of BIRD, it supports OSPFv2, RIPv2 and BGP
protocols.

$(call Package/bird1/Default/description2)
endef

define Package/bird1c-ipv4/description
$(call Package/bird1/Default/description1)
$(call Package/bird1/Default/description3)
endef

define Package/bird1cl-ipv4/description
$(call Package/bird1/Default/description1)
$(call Package/bird1/Default/description4)
endef

define Package/bird1-ipv6/description
$(call Package/bird1/Default/description1)
This is IPv6 version of BIRD, it supports OSPFv3, RIPng and BGP
protocols.

$(call Package/bird1/Default/description2)
endef

define Package/bird1c-ipv6/description
$(call Package/bird1/Default/description1)
$(call Package/bird1/Default/description3)
endef

define Package/bird1cl-ipv6/description
$(call Package/bird1/Default/description1)
$(call Package/bird1/Default/description4)
endef

CONFIGURE_ARGS += --with-linux-headers="$(LINUX_DIR)"

TARGET_CFLAGS+=-std=gnu89

define Build/Template

$(STAMP_BUILT)-$(2): $(STAMP_PREPARED)
	$(call Build/Configure/Default,$(3))
	$(call Build/Compile/Default,)
	( cd $(PKG_BUILD_DIR); mv -f bird bird$(2); mv -f birdc birdc$(2); mv -f birdcl birdcl$(2) )
	-$(MAKE) -C $(PKG_BUILD_DIR) clean
	touch $$@

$(STAMP_BUILT): $(STAMP_BUILT)-$(2)

define Package/bird1-ipv$(2)/install
	$(INSTALL_DIR)  $$(1)/usr/sbin
	$(INSTALL_BIN)  $$(PKG_BUILD_DIR)/bird$(2) $$(1)/usr/sbin/
	$(INSTALL_DIR)  $$(1)/etc
	$(INSTALL_DATA) ./files/bird$(2).conf $$(1)/etc/
	$(INSTALL_DIR)  $$(1)/etc/init.d
	$(INSTALL_BIN)  ./files/bird$(2).init $$(1)/etc/init.d/bird$(2)

endef

define Package/bird1-ipv$(2)/conffiles
/etc/bird$(2).conf
endef

define Package/bird1c-ipv$(2)/install
	$(INSTALL_DIR) $$(1)/usr/sbin
	$(INSTALL_BIN) $$(PKG_BUILD_DIR)/birdc$(2) $$(1)/usr/sbin/
endef

define Package/bird1cl-ipv$(2)/install
	$(INSTALL_DIR) $$(1)/usr/sbin
	$(INSTALL_BIN) $$(PKG_BUILD_DIR)/birdcl$(2) $$(1)/usr/sbin/
endef

endef


$(eval $(call Build/Template,bird1-ipv4,4, --disable-ipv6))
$(eval $(call Build/Template,bird1-ipv6,6, --enable-ipv6))

$(eval $(call BuildPackage,bird1-ipv4))
$(eval $(call BuildPackage,bird1c-ipv4))
$(eval $(call BuildPackage,bird1cl-ipv4))
$(eval $(call BuildPackage,bird1-ipv6))
$(eval $(call BuildPackage,bird1c-ipv6))
$(eval $(call BuildPackage,bird1cl-ipv6))
