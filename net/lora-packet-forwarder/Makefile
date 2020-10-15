#
# Copyright (C) 2019 Xue Liu <liuxuenetmail@gmail>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lora-packet-forwarder
PKG_VERSION:=4.0.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://codeload.github.com/Lora-net/packet_forwarder/tar.gz/v$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=e68fadf6f1d2e5e7b601e504d5efb48b0a8f374c2c29c0476ab2fe9db68d33ae
PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_DIR:=$(BUILD_DIR)/packet_forwarder-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/lora-packet-forwarder
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=LoRaWAN
  TITLE:=Semtech packet-forwarder program
  DEPENDS:=+libloragw +libubox-lua +libuci-lua +dkjson
endef

define Package/lora-packet-forwarder/description
  A LoRa packet forwarder is a program running on the host of a LoRa gateway
  that forwards RF packets receive by the concentrator to a server through a
  IP/UDP link, and emits RF packets that are sent by the server.
endef

define Package/lora-packet-forwarder-utils
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=LoRaWAN
  TITLE:=Utilities for lora pakcet forwarder
  DEPENDS:=+libloragw
endef

define Package/lora-packet-forwarder/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lora_pkt_fwd/lora_pkt_fwd $(1)/usr/sbin
	$(INSTALL_BIN) ./files/gen_lora_global_conf $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/lora_pkt_fwd.init $(1)/etc/init.d/lora_pkt_fwd
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/lora-global.config $(1)/etc/config/lora-global
endef

define Package/lora-packet-forwarder-utils/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/util_ack $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/util_sink $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/util_tx_test $(1)/usr/sbin
endef

$(eval $(call BuildPackage,lora-packet-forwarder))
$(eval $(call BuildPackage,lora-packet-forwarder-utils))
