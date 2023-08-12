#
# Copyright (C) 2023
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=python-ble2mqtt
PKG_VERSION:=0.1.8
PKG_RELEASE:=1

PYPI_NAME:=ble2mqtt
PKG_HASH:=206f707f5ad04b72247b1e772a569e14167e109f4e9f13d1d74eb4b049d4e6da

PKG_MAINTAINER:=Quintin Hill <stuff@quintin.me.uk>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-ble2mqtt
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Bluetooth to MQTT bridge
  URL:=https://github.com/devbis/ble2mqtt/
  DEPENDS:=+python3-light +python3-aio-mqtt-mod +python3-asyncio +python3-bleak +python3-logging +python3-uuid
endef

define Package/python3-ble2mqtt/description
  Bluetooth to MQTT bridge, add your bluetooth-capable (including controllable)
  devices to your smart home
endef

define Py3Package/python3-ble2mqtt/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ble2mqtt.init $(1)/etc/init.d/ble2mqtt
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
endef

$(eval $(call Py3Package,python3-ble2mqtt))
$(eval $(call BuildPackage,python3-ble2mqtt))
$(eval $(call BuildPackage,python3-ble2mqtt-src))
