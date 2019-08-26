#
# Copyright (C) 2007-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=babeld
PKG_VERSION:=1.9.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.irif.fr/~jch/software/files/
PKG_HASH:=1e1b3c01dd929177bc8d027aff1494da75e1e567e1f60df3bb45a78d5f1ca0b4

PKG_MAINTAINER:=Gabriel Kerneis <gabriel@kerneis.info>, \
	Baptiste Jonglez <openwrt-pkg@bitsofnetworks.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENCE

include $(INCLUDE_DIR)/package.mk

define Package/babeld
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=A loop-avoiding distance-vector routing protocol
  URL:=https://www.irif.fr/~jch/software/babel/
  DEPENDS:=@IPV6
endef

define Package/babeld/description
  Babel is a loop-avoiding distance-vector routing protocol for IPv6 and IPv4
  with fast convergence properties. It is based on the ideas in DSDV, AODV and
  Cisco's EIGRP, but is designed to work well not only in wired networks but
  also in wireless mesh networks, and has been extended with support for
  overlay networks. Babel is in the process of becoming an IETF Standard.
endef

define Package/babeld/conffiles
/etc/babeld.conf
/etc/config/babeld
endef

MAKE_FLAGS+= \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDLIBS="" \

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
