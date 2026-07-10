#
# Copyright (C) 2016 Velocloud Inc.
# Copyright (C) 2016 Aleksander Morgado <aleksander@aleksander.es>
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=modemmanager
PKG_VERSION:=1.24.0
PKG_RELEASE:=11

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.freedesktop.org/mobile-broadband/ModemManager.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=b81e0fc5a112fa52dd7ec72cdb684e10b04755a3492ea392cf6cde5688bb0e03

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

define Package/modemmanager/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://www.freedesktop.org/wiki/Software/ModemManager
endef

define Package/modemmanager
  $(call Package/modemmanager/Default)
  TITLE:=Control utility for any kind of mobile broadband modem
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

define Package/modemmanager-rpcd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=RPC interface for ModemManager for rpcd
  URL:=https://www.freedesktop.org/wiki/Software/ModemManager
  DEPENDS:= \
	modemmanager \
	+lua \
	+lua-cjson
endef

define Package/modemmanager-rpcd/description
  ModemManager is a D-Bus-activated service which allows controlling mobile
  broadband modems.

  This package enables an rpcd interface for getting information from
  ModemManager using e.g. ubus.
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
	-Dbuiltin_plugins=$(if $(CONFIG_MODEMMANAGER_WITH_BUILTIN_PLUGINS),true,false) \
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
	chmod 644 $(1)/etc/dbus-1/system.d/org.freedesktop.ModemManager1.conf

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

ifeq ($(CONFIG_MODEMMANAGER_WITH_NETIFD),y)
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/lib/netifd/proto/modemmanager.sh \
		$(1)/lib/netifd/proto
endif
endef

# 1: shared name
define BuildShared

  define Package/modemmanager-shared-$(1)
    $(call Package/modemmanager/Default)
    TITLE:=$(1) shared
    DEPENDS:= \
	modemmanager
  endef

  define Package/modemmanager-shared-$(1)/config
    depends on !MODEMMANAGER_WITH_BUILTIN_PLUGINS
  endef

  define Package/modemmanager-shared-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/lib/ModemManager
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ModemManager/libmm-shared-$(1).so* \
		$$(1)/usr/lib/ModemManager
  endef

  $$(eval $$(call BuildPackage,modemmanager-shared-$(1)))
endef

# 1: plugin name/title/description
# 2: dependencies
define BuildPlugin

  define Package/modemmanager-plugin-$(1)
    $(call Package/modemmanager/Default)
    TITLE:=$(1) plugin
    DEPENDS:= \
	modemmanager \
	$(if $(2),$(2))
  endef

  define Package/modemmanager-plugin-$(1)/config
    depends on !MODEMMANAGER_WITH_BUILTIN_PLUGINS
  endef

  define Package/modemmanager-plugin-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/lib/ModemManager

	if [ "$(1)" = "mbm" ]; then \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/ModemManager/libmm-plugin-ericsson-mbm.so* \
		$$(1)/usr/lib/ModemManager ; \
	else \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/ModemManager/libmm-plugin-$(1).so* \
		$$(1)/usr/lib/ModemManager ; \
	fi
  endef

  $$(eval $$(call BuildPackage,modemmanager-plugin-$(1)))
endef

define Package/modemmanager-rpcd/install
	$(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(INSTALL_BIN) ./files/usr/libexec/rpcd/modemmanager \
		$(1)/usr/libexec/rpcd/
endef

$(eval $(call BuildPackage,modemmanager))
$(eval $(call BuildPackage,modemmanager-rpcd))
$(eval $(call BuildShared,fibocom))
$(eval $(call BuildShared,foxconn))
$(eval $(call BuildShared,icera))
$(eval $(call BuildShared,mtk))
$(eval $(call BuildShared,novatel))
$(eval $(call BuildShared,option))
$(eval $(call BuildShared,sierra))
$(eval $(call BuildShared,telit))
$(eval $(call BuildShared,xmm))
$(eval $(call BuildShared,quectel))
$(eval $(call BuildPlugin,altair-lte,))
$(eval $(call BuildPlugin,anydata,))
$(eval $(call BuildPlugin,broadmobi,))
$(eval $(call BuildPlugin,cellient,))
$(eval $(call BuildPlugin,cinterion,))
$(eval $(call BuildPlugin,dell,+modemmanager-shared-novatel +modemmanager-shared-sierra +modemmanager-shared-telit +modemmanager-shared-xmm +MODEMMANAGER_WITH_MBIM:modemmanager-shared-foxconn))
$(eval $(call BuildPlugin,dlink,))
$(eval $(call BuildPlugin,fibocom,+modemmanager-shared-xmm +modemmanager-shared-fibocom))
$(eval $(call BuildPlugin,foxconn,+modemmanager-shared-foxconn @MODEMMANAGER_WITH_MBIM))
$(eval $(call BuildPlugin,generic,))
$(eval $(call BuildPlugin,gosuncn,))
$(eval $(call BuildPlugin,haier,))
$(eval $(call BuildPlugin,huawei,))
$(eval $(call BuildPlugin,intel,+modemmanager-shared-xmm))
$(eval $(call BuildPlugin,iridium,))
$(eval $(call BuildPlugin,linktop,))
$(eval $(call BuildPlugin,longcheer,))
$(eval $(call BuildPlugin,mbm,))
$(eval $(call BuildPlugin,motorola,))
$(eval $(call BuildPlugin,mtk-legacy,+modemmanager-shared-mtk +MODEMMANAGER_WITH_MBIM:modemmanager-shared-fibocom))
$(eval $(call BuildPlugin,mtk,+modemmanager-shared-mtk +MODEMMANAGER_WITH_MBIM:modemmanager-shared-fibocom))
$(eval $(call BuildPlugin,netprisma,+modemmanager-shared-quectel))
$(eval $(call BuildPlugin,nokia,))
$(eval $(call BuildPlugin,nokia-icera,+modemmanager-shared-icera))
$(eval $(call BuildPlugin,novatel,+modemmanager-shared-novatel))
$(eval $(call BuildPlugin,novatel-lte,))
$(eval $(call BuildPlugin,option,+modemmanager-shared-option))
$(eval $(call BuildPlugin,option-hso,+modemmanager-shared-option))
$(eval $(call BuildPlugin,pantech,))
$(eval $(call BuildPlugin,qcom-soc,@MODEMMANAGER_WITH_QMI))
$(eval $(call BuildPlugin,quectel,+modemmanager-shared-quectel))
$(eval $(call BuildPlugin,rolling,+modemmanager-shared-fibocom +modemmanager-shared-mtk))
$(eval $(call BuildPlugin,samsung,+modemmanager-shared-icera))
$(eval $(call BuildPlugin,sierra-legacy,+modemmanager-shared-icera +modemmanager-shared-sierra))
$(eval $(call BuildPlugin,sierra,+modemmanager-shared-xmm))
$(eval $(call BuildPlugin,simtech,))
$(eval $(call BuildPlugin,telit,+modemmanager-shared-telit))
$(eval $(call BuildPlugin,thuraya,))
$(eval $(call BuildPlugin,tplink,))
$(eval $(call BuildPlugin,ublox,))
$(eval $(call BuildPlugin,via,))
$(eval $(call BuildPlugin,wavecom,))
$(eval $(call BuildPlugin,x22x,))
$(eval $(call BuildPlugin,zte,+modemmanager-shared-icera))
