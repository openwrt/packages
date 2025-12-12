#
# Copyright (C) 2023 David Bauer <mail@david-bauer.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=respondd
PKG_SOURCE_DATE:=2019-05-01
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/freifunk-gluon/respondd.git
PKG_SOURCE_VERSION:=58405297e76f97d4752dc7511dc15bbc7a01e586
PKG_MIRROR_HASH:=a47edea6b7e9c1f02cf5672458f7066611de6cdfe45dd62cbb5b9a910c2435ef

PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>
PKG_LICENSE:=BSD-2-Clause

CMAKE_SOURCE_SUBDIR:=src

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/respondd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=@IPV6 +libjson-c
  TITLE:=Lightweight metadata multicast-responder
endef

define Package/respondd/description
respondd is a server distributing information within a network.

For doing so, respondd spawns a UDP socket (in Gluon 1001/udp),
optionally joining a multicast group. When a request is received,
the information requested is transmitted to the requester.

All information is organized in a non-hierarchical namespace.
Each entry identifies a request name (e.g. statistics, nodeinfo, ...)
implemented by at least one "provider" C module. The respond is the
result of merging the outputs of all providers for the given request
name.
endef

define Package/respondd/conffiles
/etc/config/respondd
endef

define Package/respondd/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_CONF) ./files/respondd.config $(1)/etc/config/respondd
	$(INSTALL_BIN) ./files/respondd.init $(1)/etc/init.d/respondd
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/respondd $(1)/usr/bin/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/respondd.h $(1)/usr/include/
endef

$(eval $(call BuildPackage,respondd))
