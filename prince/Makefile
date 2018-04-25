# 
# Copyright (C) 2009-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=prince
PKG_VERSION:=v0.4
PKG_RELEASE:=1

# out of source build
CMAKE_BINARY_SUBDIR:=build

PKG_BUILD_DIR:=$(BUILD_DIR)/prince-$(PKG_VERSION)
PKG_MIRROR_HASH:=19a3cae09f28a5ef07fc0f5ff12cf62c776a94fbf1626336ab04951775c104de
PKG_INSTALL:=0
PKG_LICENSE:=MIT
PKG_SOURCE:=prince-$(PKG_VERSION).tar.xz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=prince-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/AdvancedNetworkingSystems/prince.git
PKG_SOURCE_VERSION:=v0.4
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/prince
	SECTION :=net
	CATEGORY :=Network
	SUBMENU :=Routing and Redirection
	Mantainer :=Gabriele Gemmi <gabriel@autistici.org>
	TITLE :=Prince
	URL :=https://github.com/AdvancedNetworkingSystems/prince
	MENU :=0
	DEPENDS := +libjson-c +libpthread
endef

define Package/prince/description
	Prince is an open source implementation of the PopRouting Algorithm.
	It has been developed as a Google Summer of Code Project in collaboration with Freifunk and the University of Trento.

	Prince fetches topology data from a Link State routing daemon (OONF, OLSR, OSPF, etc),
	calculates the betweenness centrality using the topology and then computes the
	the timers' optimal values using these data. At the end of the computation the timers are pushed back to the routing daemon.
	Since v0.4 it supports both OONF and OLSRd.
endef

define Package/prince/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/prince $(1)/usr/bin/prince
	$(INSTALL_BIN) ./files/prince.init $(1)/etc/init.d/prince
	$(INSTALL_DATA) ./files/prince.conf $(1)/etc/prince.conf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/libprince_oonf.so $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/libprince_olsr.so $(1)/usr/lib
endef

CFLAGS += $(TARGET_CFLAGS) $(TARGET_CPPFLAGS)
LDFLAGS += $(TARGET_LDFLAGS)

$(eval $(call BuildPackage,prince))
