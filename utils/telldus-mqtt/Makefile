#
# Copyright (C) Peter Liedholm
#
# This is free software, licensed under the GNU General Public License v2.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=telldus-mqtt
PKG_VERSION:=0.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/PeterFromSweden/telldus-mqtt.git
PKG_SOURCE_VERSION:=8ee4187fd4ea44541b637bb63ed34d4cc182b2a4
PKG_MIRROR_HASH:=e5c5ab541ffe45f1b4f9e978abed82837fb65f9367120c209890d231d44c43ec

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
