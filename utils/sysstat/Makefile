#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sysstat
PKG_VERSION:=11.6.0
PKG_RELEASE:=2

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Marko Ratkaj <marko.ratkaj@sartura.hr>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://pagesperso-orange.fr/sebastien.godard/
PKG_HASH:=14bb696545cba0d99e3492092c9ed15fe9b6da79df349695251b41d345e969a7

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/sysstat
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Sysstat performance monitoring tools
  URL:=http://pagesperso-orange.fr/sebastien.godard/index.html
endef

define Package/sysstat/description
 The sysstat utilities are a collection of performance monitoring tools for
 Linux. These include sar, sadf, mpstat, iostat, pidstat and sa tools.
endef

define Package/sysstat/conffiles
/etc/sysstat/sysstat.ioconf
/etc/sysstat/sysstat
endef

CONFIGURE_VARS+= \
	sa_lib_dir="/usr/lib/sysstat" \
	sa_dir="/var/log/sysstat" \
	conf_dir="/etc/sysstat"

CONFIGURE_ARGS+= \
	--disable-documentation \
	--disable-largefile \
	--disable-sensors \
	--disable-nls

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
