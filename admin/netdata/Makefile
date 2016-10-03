#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=netdata
PKG_VERSION:=1.3.0
PKG_RELEASE:=2
PKG_MAINTAINER:=Sebastian Careba <nitroshift@yahoo.com>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://firehol.org/download/netdata/releases/v$(PKG_VERSION)
PKG_SOURCE_VERSION:=f8ed1eac764386b839fbd2db0f41e664
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

TARGET_CFLAGS+= -DNETDATA_NO_ATOMIC_INSTRUCTIONS=1

include $(INCLUDE_DIR)/package.mk

define Package/netdata
  SECTION:=admin
  CATEGORY:=Administration
  DEPENDS:=+zlib +libuuid
  TITLE:=Real-time performance monitoring tool
  URL:=http://netdata.firehol.org/
endef

define Package/netdata/description
  netdata is a highly optimized Linux daemon providing real-time performance
  monitoring for Linux systems, applications and SNMP devices over the web.
endef

define Package/netdata/conffiles
/etc/netdata/
endef

define Package/netdata/install
	$(INSTALL_DIR) $(1)/etc/netdata
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/netdata/apps_groups.conf $(1)/etc/netdata
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/netdata/charts.d.conf $(1)/etc/netdata
	$(INSTALL_CONF) ./files/netdata.conf $(1)/etc/netdata
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/netdata.init $(1)/etc/init.d/netdata
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/netdata $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/share/netdata
	$(INSTALL_DIR) $(1)/usr/lib/netdata
	$(CP) $(PKG_INSTALL_DIR)/usr/share/netdata $(1)/usr/share
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/netdata $(1)/usr/lib
	chmod 4755 $(1)/usr/lib/netdata/plugins.d/apps.plugin
endef

$(eval $(call BuildPackage,netdata))
