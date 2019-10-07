#
# Copyright (C) 2016 Velocloud Inc.
# Copyright (C) 2016 Aleksander Morgado <aleksander@aleksander.es>
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=modemmanager
PKG_VERSION:=1.10.6
PKG_RELEASE:=1

PKG_SOURCE:=ModemManager-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.freedesktop.org/software/ModemManager
PKG_HASH=3c2ca73782215664141042422759899ca9846440fc26d6223c7cf7ea4dd3c996
PKG_BUILD_DIR:=$(BUILD_DIR)/ModemManager-$(PKG_VERSION)

PKG_MAINTAINER:=Nicholas Smith <nicholas.smith@telcoantennas.com.au>
LICENSE:=GPL-2.0-or-later
LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

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
	+MODEMMANAGER_WITH_MBIM:libmbim \
	+MODEMMANAGER_WITH_QMI:libqmi
endef

define Package/modemmanager/description
  ModemManager is a D-Bus-activated service which allows controlling mobile
  broadband modems. Add kernel modules for your modems as needed.
  Select Utilities/usb-modeswitch if needed.
endef

CONFIGURE_ARGS += \
	--without-polkit \
	--without-udev \
	--without-suspend-resume \
	--with-systemdsystemunitdir=no \
	--disable-rpath \
	--disable-gtk-doc 

ifdef CONFIG_MODEMMANAGER_WITH_MBIM
  CONFIGURE_ARGS += --with-mbim
else
  CONFIGURE_ARGS += --without-mbim
endif

ifdef CONFIG_MODEMMANAGER_WITH_QMI
  CONFIGURE_ARGS += --with-qmi
else
  CONFIGURE_ARGS += --without-qmi
endif

define Build/Prepare
	$(call Build/Prepare/Default)
	( cd "$(PKG_BUILD_DIR)"; \
		printf "all:\ninstall:\n" >po/Makefile.in.in; \
	)
endef

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
endef

define Package/modemmanager/install
	$(INSTALL_DIR) $(1)/lib/udev/rules.d
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/lib/udev/rules.d/*.rules $(1)/lib/udev/rules.d

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ModemManager $(1)/usr/sbin

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mmcli $(1)/usr/bin

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmm-glib.so.* $(1)/usr/lib

	$(INSTALL_DIR) $(1)/usr/lib/ModemManager
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ModemManager/libmm-plugin-*.so* $(1)/usr/lib/ModemManager

	$(INSTALL_DIR) $(1)/etc/dbus-1/system.d
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/dbus-1/system.d/org.freedesktop.ModemManager1.conf $(1)/etc/dbus-1/system.d

	$(INSTALL_DIR) $(1)/usr/share/dbus-1/system-services
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/dbus-1/system-services/org.freedesktop.ModemManager1.service $(1)/usr/share/dbus-1/system-services

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/modemmanager.init $(1)/etc/init.d/modemmanager

	$(INSTALL_DIR) $(1)/etc/hotplug.d/net
	$(INSTALL_DATA) ./files/25-modemmanager-net $(1)/etc/hotplug.d/net

	$(INSTALL_DIR) $(1)/etc/hotplug.d/tty
	$(INSTALL_DATA) ./files/25-modemmanager-tty $(1)/etc/hotplug.d/tty

	$(INSTALL_DIR) $(1)/etc/modemmanager
	$(INSTALL_DATA) ./files/modemmanager.common $(1)/etc/modemmanager/modemmanager.common

	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/modemmanager.proto $(1)/lib/netifd/proto/modemmanager.sh
endef

$(eval $(call RequireCommand,xsltproc, \
        $(PKG_NAME) requires xsltproc installed on the host-system. \
))

$(eval $(call RequireCommand,intltoolize, \
        $(PKG_NAME) requires intltool installed on the host-system. \
))

$(eval $(call BuildPackage,modemmanager))
