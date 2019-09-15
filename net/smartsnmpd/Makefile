#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=smartsnmpd
PKG_VERSION:=2015-02-22
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/credosemi/smartsnmp
PKG_SOURCE_VERSION:=ca1d455fd06748caa629fe7ad16a47cec8877b93
PKG_MIRROR_HASH:=fda89ec37944b4f800eb3c0147678745b57f08c87f10d246d3c9d165a43418b4

PKG_MAINTAINER:=Xiongfei Guo <xfguo@credosemi.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=scons/host

include $(INCLUDE_DIR)/package.mk
include ../../devel/scons/scons.mk

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

ifeq ($(CONFIG_BIG_ENDIAN),y)
	TARGET_CFLAGS += -DBIG_ENDIAN
else
	TARGET_CFLAGS += -DLITTLE_ENDIAN
endif

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

