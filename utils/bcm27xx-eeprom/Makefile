include $(TOPDIR)/rules.mk

PKG_NAME:=bcm27xx-eeprom
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/raspberrypi/rpi-eeprom
PKG_SOURCE_DATE:=2025-02-12
PKG_SOURCE_VERSION:=c954a72f6301b8ac0fc4b0fe252e1c5024d2862b
PKG_MIRROR_HASH:=fb45c5d65c70dc7b68c8b63ab2641706e44a54042c6817d7a9167c55d51f3794

PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>
PKG_LICENSE:=BSD-3-Clause Custom
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

TAR_OPTIONS:=--strip-components 1 $(TAR_OPTIONS)
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

define Package/bcm27xx-eeprom/Default
  SECTION:=utils
  CATEGORY:=Utilities
endef

define Package/bcm27xx-eeprom
$(call Package/bcm27xx-eeprom/Default)
  TITLE:=BCM27xx EEPROM tools
  DEPENDS:=bcm27xx-utils +blkid +coreutils +coreutils-od +mount-utils +pciutils +python3-light
endef

define Package/bcm2711-eeprom
$(call Package/bcm27xx-eeprom/Default)
  TITLE:=BCM2711 EEPROM tools
  DEPENDS:=+bcm27xx-eeprom
endef

define Package/bcm2712-eeprom
$(call Package/bcm27xx-eeprom/Default)
  TITLE:=BCM2712 EEPROM tools
  DEPENDS:=+bcm27xx-eeprom
endef

define Package/bcm27xx-eeprom/description
  BCM27xx EEPROM config and update tools.
endef

define Package/bcm2711-eeprom/description
  BCM2711 EEPROM config and update tools.
endef

define Package/bcm2712-eeprom/description
  BCM2712 EEPROM config and update tools.
endef

define Build/Compile
	true
endef

define Package/bcm27xx-eeprom/conffiles
/etc/bcm27xx-eeprom.conf
endef

define Package/bcm27xx-eeprom/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/rpi-eeprom-update-default $(1)/etc/bcm27xx-eeprom.conf

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rpi-eeprom-config $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rpi-eeprom-digest $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rpi-eeprom-update $(1)/usr/bin
endef

define Package/bcm2711-eeprom/install
	$(INSTALL_DIR) $(1)/lib/firmware/raspberrypi/bootloader-2711
	$(INSTALL_DIR) $(1)/lib/firmware/raspberrypi/bootloader-2711/latest

	$(CP) $(PKG_BUILD_DIR)/firmware-2711/release-notes.md $(1)/lib/firmware/raspberrypi/bootloader-2711
	$(CP) $(PKG_BUILD_DIR)/firmware-2711/latest/pieeprom-2025-02-11.bin $(1)/lib/firmware/raspberrypi/bootloader-2711/latest
	$(CP) $(PKG_BUILD_DIR)/firmware-2711/latest/recovery.bin $(1)/lib/firmware/raspberrypi/bootloader-2711/latest
	$(CP) $(PKG_BUILD_DIR)/firmware-2711/latest/vl805-000138c0.bin $(1)/lib/firmware/raspberrypi/bootloader-2711/latest
endef

define Package/bcm2712-eeprom/install
	$(INSTALL_DIR) $(1)/lib/firmware/raspberrypi/bootloader-2712
	$(INSTALL_DIR) $(1)/lib/firmware/raspberrypi/bootloader-2712/latest

	$(CP) $(PKG_BUILD_DIR)/firmware-2712/release-notes.md $(1)/lib/firmware/raspberrypi/bootloader-2712
	$(CP) $(PKG_BUILD_DIR)/firmware-2712/latest/pieeprom-2025-02-12.bin $(1)/lib/firmware/raspberrypi/bootloader-2712/latest
	$(CP) $(PKG_BUILD_DIR)/firmware-2712/latest/recovery.bin $(1)/lib/firmware/raspberrypi/bootloader-2712/latest
endef

$(eval $(call BuildPackage,bcm27xx-eeprom))
$(eval $(call BuildPackage,bcm2711-eeprom))
$(eval $(call BuildPackage,bcm2712-eeprom))
