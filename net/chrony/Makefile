#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=chrony
PKG_VERSION:=2.4.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://download.tuxfamily.org/chrony/
PKG_MD5SUM:=d08dd5a7d79a89891d119adcccb4397d

PKG_MAINTAINER:=Miroslav Lichvar <mlichvar0@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=+pps-tools

include $(INCLUDE_DIR)/package.mk

define Package/chrony
  SUBMENU:=Time Synchronization
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libcap +libpthread
  USERID:=chrony=323:chrony=323
  TITLE:=A versatile NTP client and server
  URL:=http://chrony.tuxfamily.org/
endef

define Package/chrony/description
	An NTP client and server designed to perform well in a wide range
	of conditions. It can synchronize the system clock with NTP servers,
	reference clocks, and manual input using wristwatch and keyboard.
endef

define Package/chrony/conffiles
/etc/chrony/chrony.conf
/etc/config/chrony
endef

CONFIGURE_ARGS+= \
	--host-machine=$(shell echo $(GNU_TARGET_NAME) | sed -e 's/-.*//') \
	--host-release="" \
	--host-system=Linux \
	--sysconfdir=/etc/chrony \
	--prefix=/usr \
	--chronysockdir=/var/run/chrony \
	--disable-readline \
	--disable-rtc \
	--with-user=chrony

CONFIGURE_VARS+=CPPFLAGS=-DNDEBUG

define Package/chrony/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chronyd $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chronyc $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/chrony
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/chrony.hotplug $(1)/etc/hotplug.d/iface/20-chrony
	$(INSTALL_BIN) ./files/chronyd.init $(1)/etc/init.d/chronyd
	$(INSTALL_CONF) ./files/chrony.config $(1)/etc/config/chrony
	$(INSTALL_CONF) ./files/chrony.conf $(1)/etc/chrony/chrony.conf
endef

$(eval $(call BuildPackage,chrony))
