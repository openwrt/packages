include $(TOPDIR)/rules.mk

PKG_NAME:=bcm27xx-eeprom
PKG_VERSION:=v.2024.01.05-2712
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/raspberrypi/rpi-eeprom/tar.gz/$(PKG_VERSION)?
PKG_HASH:=ae1d9f10e4383ee39b291b4b3be1be583f6f32f806f65a1431da65ca4ccffe39

PKG_LICENSE:=BSD-3-Clause Custom
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

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
  DEPENDS:=bcm27xx-userland +blkid +coreutils +coreutils-od +mount-utils +pciutils +python3-light
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
	$(INSTALL_DIR) $(1)/lib/firmware/raspberrypi/bootloader-2711/default
	$(INSTALL_DIR) $(1)/lib/firmware/raspberrypi/bootloader-2711/latest

	$(CP) $(PKG_BUILD_DIR)/firmware-2711/release-notes.md $(1)/lib/firmware/raspberrypi/bootloader-2711
	$(CP) $(PKG_BUILD_DIR)/firmware-2711/default $(1)/lib/firmware/raspberrypi/bootloader-2711
	$(CP) $(PKG_BUILD_DIR)/firmware-2711/latest $(1)/lib/firmware/raspberrypi/bootloader-2711
endef

define Package/bcm2712-eeprom/install
	$(INSTALL_DIR) $(1)/lib/firmware/raspberrypi/bootloader-2712
	$(INSTALL_DIR) $(1)/lib/firmware/raspberrypi/bootloader-2712/default
	$(INSTALL_DIR) $(1)/lib/firmware/raspberrypi/bootloader-2712/latest

	$(CP) $(PKG_BUILD_DIR)/firmware-2712/release-notes.md $(1)/lib/firmware/raspberrypi/bootloader-2712
	$(CP) $(PKG_BUILD_DIR)/firmware-2712/default $(1)/lib/firmware/raspberrypi/bootloader-2712
	$(CP) $(PKG_BUILD_DIR)/firmware-2712/latest $(1)/lib/firmware/raspberrypi/bootloader-2712
endef

$(eval $(call BuildPackage,bcm27xx-eeprom))
$(eval $(call BuildPackage,bcm2711-eeprom))
$(eval $(call BuildPackage,bcm2712-eeprom))
