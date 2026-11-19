#
# Copyright (C) Peter Liedholm
#
# This is free software, licensed under the GNU General Public License v2.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=telldus-mqtt
PKG_VERSION:=0.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/PeterFromSweden/telldus-mqtt/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=48d4a144015765ae2a9bac57367b1d336cc74b260667e1251076472a2da56126

PKG_MAINTAINER:=Peter Liedholm <PeterFromSwe884@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += -DBUILD_TESTING=OFF

define Package/telldus-mqtt
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Telldus MQTT converter
  DEPENDS:=+telldus-core +libmosquitto +cJSON +ucode +ucode-mod-uci +ucode-mod-fs
endef

define Package/telldus-mqtt/description
  MQTT protocol converter for Telldus USB-based 433 MHz RF transceiver for home automation.
  Settings in the UCI config telldus-mqtt (see luci-app-telldus-mqtt).
  Please see https://github.com/PeterFromSweden/telldus-mqtt/blob/master/Readme.md for more information.
endef

# telldus-mqtt.json: only for the upgrade from 0.4. The uci-defaults script
# copies it to UCI. The daemon reads /var/etc/telldus-mqtt.json (from UCI).
define Package/telldus-mqtt/conffiles
/etc/config/telldus-mqtt
/etc/telldus-mqtt/telldus-mqtt.json
/etc/telldus-mqtt/telldus-mqtt-homeassistant.json
endef

define Package/telldus-mqtt/install
	$(INSTALL_DIR)  $(1)/usr/bin
	$(INSTALL_BIN)  $(PKG_INSTALL_DIR)/usr/bin/telldus-mqtt $(1)/usr/bin
	$(INSTALL_DIR)  $(1)/etc/telldus-mqtt
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/etc/telldus-mqtt/telldus-mqtt.json $(1)/etc/telldus-mqtt
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/etc/telldus-mqtt/telldus-mqtt-homeassistant.json $(1)/etc/telldus-mqtt
	$(INSTALL_DIR)  $(1)/usr/share/telldus-mqtt
	$(INSTALL_DATA) ./files/telldus-mqtt-*.uc $(1)/usr/share/telldus-mqtt
	$(INSTALL_DIR)  $(1)/etc/config
	$(INSTALL_CONF) ./files/telldus-mqtt.config $(1)/etc/config/telldus-mqtt
	$(INSTALL_DIR)  $(1)/etc/uci-defaults
	$(INSTALL_BIN)  ./files/telldus-mqtt.defaults $(1)/etc/uci-defaults/telldus-mqtt
	$(INSTALL_DIR)  $(1)/etc/init.d
	$(INSTALL_BIN)  ./files/telldus-mqtt.init $(1)/etc/init.d/telldus-mqtt
endef

$(eval $(call BuildPackage,telldus-mqtt))
