#
# Copyright (C) 2016 Velocloud Inc.
# Copyright (C) 2016 Aleksander Morgado <aleksander@aleksander.es>
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=modemmanager
PKG_VERSION:=1.22.0
PKG_RELEASE:=13

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.freedesktop.org/mobile-broadband/ModemManager.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=72d129a00d51f0acf4c421f02dd342728ca42980bd9644e3c9a69ca0792fd60b

PKG_MAINTAINER:=Nicholas Smith <nicholas@nbembedded.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=glib2/host libxslt/host
PKG_BUILD_FLAGS:=gc-sections

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

TARGET_CFLAGS += -fno-merge-all-constants -fmerge-constants

define Package/modemmanager/config
  source "$(SOURCE)/Config.in"
endef

define Package/modemmanager
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Control utility for any kind of mobile broadband modem
  URL:=https://www.freedesktop.org/wiki/Software/ModemManager
  DEPENDS:= \
	$(INTL_DEPENDS) \
	+glib2 \
	+dbus \
	+ppp \
	+MODEMMANAGER_WITH_MBIM:libmbim \
	+MODEMMANAGER_WITH_QMI:libqmi \
	+MODEMMANAGER_WITH_QRTR:libqrtr-glib
endef

define Package/modemmanager/description
  ModemManager is a D-Bus-activated service which allows controlling mobile
  broadband modems. Add kernel modules for your modems as needed.
  Select Utilities/usb-modeswitch if needed.
endef

MESON_ARGS += \
	-Dudev=false \
	-Dudevdir=/lib/udev \
	-Dtests=false \
	-Dsystemdsystemunitdir=no \
	-Dsystemd_suspend_resume=false \
	-Dsystemd_journal=false \
	-Dpolkit=no \
	-Dintrospection=false \
	-Dman=false \
	-Dbash_completion=false \
	-Dbuiltin_plugins=true \
	-Db_lto=true \
	-Dmbim=$(if $(CONFIG_MODEMMANAGER_WITH_MBIM),true,false) \
	-Dqmi=$(if $(CONFIG_MODEMMANAGER_WITH_QMI),true,false) \
	-Dqrtr=$(if $(CONFIG_MODEMMANAGER_WITH_QRTR),true,false) \
	-Dat_command_via_dbus=$(if $(CONFIG_MODEMMANAGER_WITH_AT_COMMAND_VIA_DBUS),true,false)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/ModemManager
	$(CP) $(PKG_INSTALL_DIR)/usr/include/ModemManager/*.h $(1)/usr/include/ModemManager
	$(INSTALL_DIR) $(1)/usr/include/libmm-glib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libmm-glib/*.h $(1)/usr/include/libmm-glib
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmm-glib.so* $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/ModemManager.pc $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/mm-glib.pc $(1)/usr/lib/pkgconfig
	$(INSTALL_DIR) $(1)/usr/share/dbus-1/interfaces
	$(CP) $(PKG_BUILD_DIR)/introspection/org.freedesktop.ModemManager1.* $(1)/usr/share/dbus-1/interfaces
endef

define Package/modemmanager/install
	$(INSTALL_DIR) $(1)/lib/udev/rules.d
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/lib/udev/rules.d/*.rules $(1)/lib/udev/rules.d

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ModemManager $(1)/usr/sbin
	$(INSTALL_BIN) ./files/usr/sbin/ModemManager-wrapper $(1)/usr/sbin
	$(INSTALL_BIN) ./files/usr/sbin/ModemManager-monitor $(1)/usr/sbin

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mmcli $(1)/usr/bin

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmm-glib.so.* $(1)/usr/lib

	$(INSTALL_DIR) $(1)/usr/lib/ModemManager/connection.d
	$(INSTALL_BIN) ./files/usr/lib/ModemManager/connection.d/10-report-down \
		$(1)/usr/lib/ModemManager/connection.d

	$(INSTALL_DIR) $(1)/etc/dbus-1/system.d
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/dbus-1/system.d/org.freedesktop.ModemManager1.conf $(1)/etc/dbus-1/system.d

	$(INSTALL_DIR) $(1)/usr/share/dbus-1/system-services
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/dbus-1/system-services/org.freedesktop.ModemManager1.service $(1)/usr/share/dbus-1/system-services

	$(INSTALL_DIR) $(1)/usr/share/ModemManager
	$$(if $$(wildcard $(PKG_INSTALL_DIR)/usr/share/ModemManager/*.conf),$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/ModemManager/*.conf $(1)/usr/share/ModemManager,)
	$(INSTALL_DATA) ./files/usr/share/ModemManager/modemmanager.common \
		$(1)/usr/share/ModemManager

	$(INSTALL_DIR) $(1)/usr/share/ModemManager/fcc-unlock.available.d
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/ModemManager/fcc-unlock.available.d/* $(1)/usr/share/ModemManager/fcc-unlock.available.d

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/modemmanager \
		$(1)/etc/init.d/modemmanager

	$(INSTALL_DIR) $(1)/etc/hotplug.d/net
	$(INSTALL_DATA) ./files/etc/hotplug.d/net/25-modemmanager-net \
		$(1)/etc/hotplug.d/net

	$(INSTALL_DIR) $(1)/etc/hotplug.d/tty
	$(INSTALL_DATA) ./files/etc/hotplug.d/tty/25-modemmanager-tty \
		$(1)/etc/hotplug.d/tty

	$(INSTALL_DIR) $(1)/etc/hotplug.d/wwan
	$(INSTALL_DATA) ./files/etc/hotplug.d/wwan/25-modemmanager-wwan \
		$(1)/etc/hotplug.d/wwan

	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/lib/netifd/proto/modemmanager.sh \
		$(1)/lib/netifd/proto
endef

$(eval $(call BuildPackage,modemmanager))
