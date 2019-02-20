#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lora-picogw-hal
PKG_VERSION:=0.2.2
PKG_RELEASE:=1

PKG_SOURCE:=V$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Lora-net/picoGW_hal/archive/
PKG_HASH:=4841940f621342ba55767f79b738669417a7e572d7143d94e2b512ae8c45d05f
PKG_MAINTAINER:=Roman Valls Guimera <brainstorm+openwrt@nopcode.org>
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_DIR:=$(BUILD_DIR)/picoGW_hal-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/libloragw/description
  Host driver/HAL to build a LoRa Picocell Gateway which communicates through USB with a concentrator board based on Semtech SX1308 multi-channel modem and SX1257/SX1255 RF transceivers.
endef

define Package/lora-picogw-hal
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=LoRaWAN
  TITLE:=Host driver/HAL to build a LoRa Picocell Gateway.
endef

TARGET_CFLAGS += $(FPIC) -Wall -Wextra -std=c99 -Iinc -I. -lm

define Package/lora-picogw-hal/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util_chip_id/util_chip_id $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util_boot/util_boot $(1)/usr/sbin
endef

$(eval $(call BuildPackage,lora-picogw-hal))
