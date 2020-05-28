include $(TOPDIR)/rules.mk

PKG_NAME:=bcm27xx-eeprom
PKG_VERSION:=fd2ea72b2677504f41298c9137647aa057f67f47
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/raspberrypi/rpi-eeprom/tar.gz/$(PKG_VERSION)?
PKG_HASH:=3a4e1db25db8188535ad0ad12a6e40e2ff927b20cd21b1b5ff783c2fde966308

PKG_LICENSE:=BSD-3-Clause Custom
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

include $(INCLUDE_DIR)/package.mk

TAR_OPTIONS:=--strip-components 1 $(TAR_OPTIONS)
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

define Package/bcm27xx-eeprom
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=bcm27xx-userland +blkid +pciutils +python3-light
  TITLE:=BCM27xx EEPROM tools
endef

define Package/bcm27xx-eeprom/description
  BCM27xx EEPROM tools.
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
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rpi-eeprom-update $(1)/usr/bin

	$(INSTALL_DIR) $(1)/lib/firmware/raspberrypi/bootloader
	$(CP) $(PKG_BUILD_DIR)/firmware/release-notes.md $(1)/lib/firmware/raspberrypi/bootloader

	$(INSTALL_DIR) $(1)/lib/firmware/raspberrypi/bootloader/critical
	$(CP) $(PKG_BUILD_DIR)/firmware/critical/ $(1)/lib/firmware/raspberrypi/bootloader/

	$(INSTALL_DIR) $(1)/lib/firmware/raspberrypi/bootloader/stable
	$(CP) $(PKG_BUILD_DIR)/firmware/stable/ $(1)/lib/firmware/raspberrypi/bootloader/
endef

$(eval $(call BuildPackage,bcm27xx-eeprom))
