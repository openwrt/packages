#
# Copyright (C) Peter Liedholm
#
# This is free software, licensed under the GNU General Public License v2.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=telldus-mqtt
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/PeterFromSweden/telldus-mqtt.git
PKG_SOURCE_VERSION:=e7f531c3d20f70977369fbb173fc74828efb32b8
PKG_MIRROR_HASH:=95a61fbd928f3579f41491b91182b274b2d42faabf28c4a8f7c5eb1691f0ad2e

PKG_MAINTAINER:=Peter Liedholm <PeterFromSwe884@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/telldus-mqtt
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=Telldus MQTT converter
	DEPENDS:= +telldus-core +libmosquitto +cJSON
endef

define Package/telldus-mqtt/description
	MQTT protocol converter for Telldus USB-based 433 MHz RF transceiver for home automation.
endef

define Package/telldus-mqtt/conffiles
/etc/telldus-mqtt/telldus-mqtt.json
/etc/telldus-mqtt/telldus-mqtt-homeassistant.json
endef

define Package/telldus-mqtt/install
	$(INSTALL_DIR)  $(1)/usr/bin
	$(INSTALL_BIN)  $(PKG_INSTALL_DIR)/usr/bin/telldus-mqtt $(1)/usr/bin
	$(INSTALL_DIR)  $(1)/etc/telldus-mqtt/
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/etc/telldus-mqtt/telldus-mqtt.json $(1)/etc/telldus-mqtt
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/etc/telldus-mqtt/telldus-mqtt-homeassistant.json $(1)/etc/telldus-mqtt
	$(INSTALL_DIR)  $(1)/etc/init.d
	$(INSTALL_BIN)  ./files/telldus-mqtt $(1)/etc/init.d
endef

$(eval $(call BuildPackage,telldus-mqtt))
