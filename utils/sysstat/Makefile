#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sysstat
PKG_VERSION:=12.7.5
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://sysstat.github.io/sysstat-packages
PKG_HASH:=57664040a549d33bb06a1121c7124d4cadd9b8b35f815856c194393047cd4d6b

PKG_MAINTAINER:=Marko Ratkaj <markoratkaj@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:sysstat_project:sysstat

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/sysstat
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Sysstat performance monitoring tools
  URL:=https://sysstat.github.io/
  DEPENDS:=$(INTL_DEPENDS) +xz-utils +xz
endef

define Package/sysstat/description
 The sysstat utilities are a collection of performance monitoring tools for
 Linux. These include sar, sadf, mpstat, iostat, pidstat and sa tools.
endef

define Package/sysstat/conffiles
/etc/config/sysstat
/etc/sysstat/sysstat.ioconf
/etc/sysstat/sysstat
endef

CONFIGURE_VARS+= \
	sa_lib_dir="/usr/lib/sysstat" \
	sa_dir="/var/log/sysstat" \
	conf_dir="/etc/sysstat"

CONFIGURE_ARGS+= \
	--disable-documentation \
	--disable-sensors

define Package/sysstat/install
	$(INSTALL_DIR) $(1)/usr/lib/sysstat
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/sysstat/{sadc,sa1,sa2} $(1)/usr/lib/sysstat/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{sar,sadf,iostat,mpstat,pidstat} $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/sysstat
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/sysstat/sysstat.ioconf $(1)/etc/sysstat/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/sysstat.config $(1)/etc/config/sysstat
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/sysstat.init $(1)/etc/init.d/sysstat
endef

$(eval $(call BuildPackage,sysstat))
