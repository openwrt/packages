#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lora-picogw-packet-forwarder
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PKG_SOURCE:=V$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Lora-net/picoGW_packet_forwarder/archive/
PKG_HASH:=cc6f15be9b95e9b5c28dae97c96244cff651e303b3991b254ef4dcba3f59f562
PKG_MAINTAINER:=Roman Valls Guimera <brainstorm+openwrt@nopcode.org>
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_DIR:=$(BUILD_DIR)/picoGW_packet_forwarder-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/lora-picogw-packet-forwarder/description
  A LoRa packet forwarder running on the host of a LoRa
  Picocell Gateway that forwards RF packets receive by
  the concentrator to a server through a IP/UDP link,
  and emits RF packets that are sent by the server.
endef

define Package/lora-picogw-packet-forwarder
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=LoRaWAN
  TITLE:=A LoRa packet forwarder from Semtech.
  DEPENDS:=@lora-picogw-hal
endef

TARGET_CFLAGS += $(FPIC) -Wall -Wextra -std=c99 -Iinc -I. -lm

define Package/lora-picogw-packet-forwarder/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lora_pkt_fwd/lora_pkt_fwd $(1)/usr/sbin
endef

$(eval $(call BuildPackage,lora-picogw-packet-forwarder))
