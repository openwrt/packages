#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=smartsnmpd
PKG_VERSION:=2014-08-13
PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/credosemi/smartsnmp.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=fb93473d895f058b2d8975d3cfa280ae2a8ae98d
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=fc7f3eef8341163e21aecf6abf2492fa90362877093baef9987af3c703baa6ea


PKG_MAINTAINER:=Xiongfei Guo <xfguo@credosemi.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/scons.mk

define Package/smartsnmpd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS+=+lua +liblua +libubox +libuci-lua +libubus-lua
  TITLE:=Smart-SNMP (Agent)
  URL:=https://github.com/credosemi/smartsnmp
endef

define Package/smartsnmpd/description
smartsnmpd is an implementation of SNMP Agent. Its goal is "Easily
writing boring SNMP MIB with Lua". This package add native support
for OpenWrt. Include using ubus and uci to get system info/status. 
And, it use libubox/uloop as low level event-driven library.
endef

SCONS_OPTIONS += --transport=uloop

define Build/Configure
	(cd $(PKG_BUILD_DIR); \
		$(SCONS_VARS) \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
		scons \
			prefix=/usr \
			$(SCONS_OPTIONS) \
	)
endef

define Package/smartsnmpd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/smartsnmpd $(1)/usr/sbin/smartsnmpd

	$(INSTALL_DIR) $(1)/usr/lib/lua/smartsnmp
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/smartsnmp/core.so $(1)/usr/lib/lua/smartsnmp/core.so
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lualib/smartsnmp/*.lua $(1)/usr/lib/lua/smartsnmp/

	$(INSTALL_DIR) $(1)/usr/lib/lua/smartsnmp/mibs
	$(INSTALL_BIN) ./files/mibs/*.lua $(1)/usr/lib/lua/smartsnmp/mibs/
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/smartsnmpd.conf $(1)/etc/config/smartsnmpd

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/smartsnmpd.init $(1)/etc/init.d/smartsnmpd
endef

$(eval $(call BuildPackage,smartsnmpd))

