#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=chrony
PKG_VERSION:=2.1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://download.tuxfamily.org/chrony/
PKG_MD5SUM:=15e470a51ab6e09e65bc0a2fbc5299af

PKG_MAINTAINER:=Miroslav Lichvar <mlichvar0@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=+pps-tools

include $(INCLUDE_DIR)/package.mk

define Package/chrony
  SUBMENU:=Time Synchronization
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=
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
endef

CONFIGURE_ARGS+= \
	--host-machine=$(shell echo $(GNU_TARGET_NAME) | sed -e 's/-.*//') \
	--host-release="" \
	--host-system=Linux \
	--sysconfdir=/etc/chrony \
	--prefix=/usr \
	--disable-readline \
	--disable-linuxcaps \
	--disable-rtc \
	--disable-asyncdns

define Package/chrony/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chronyd $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chronyc $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/chrony
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/ntpd.hotplug $(1)/etc/hotplug.d/iface/20-ntpd
	$(INSTALL_BIN) ./files/ntpd.init $(1)/etc/init.d/ntpd
	$(INSTALL_CONF) ./files/ntpd.config $(1)/etc/config/ntpd
	$(INSTALL_CONF) ./files/chrony.conf $(1)/etc/chrony/chrony.conf
	$(INSTALL_CONF) ./files/chrony.keys $(1)/etc/chrony/chrony.keys
endef

$(eval $(call BuildPackage,chrony))
