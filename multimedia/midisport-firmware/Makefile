include $(TOPDIR)/rules.mk

PKG_NAME:=midisport-firmware
PKG_VERSION:=1.2
PKG_RELEASE:=1

PKG_SOURCE_URL:=@SF/usb-midi-fw/$(PKG_NAME)/$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=2aa82ef0bf26647fbdda4c2e9ed0033b41bd0f1b4020b87fa073e4462a048b2d

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE_FILES:=LICENCE

include $(INCLUDE_DIR)/package.mk

define Package/midisport-firmware
  SECTION:=firmware
  CATEGORY:=Firmware
  URL:=https://sourceforge.net/projects/usb-midi-fw
  TITLE:=M-Audio USB MIDI Firmware
  DEPENDS:=+fxload
  PKGARCH:=all
endef

define Package/midisport-firmware/description
This package allows you to use the MidiSport USB MIDI interfaces from
M-Audio/Midiman.

Supported devices:
- MidiSport 1x1
- MidiSport 2x2
- MidiSport 4x4
- MidiSport 8x8
- MidiSport Uno
- Keystation
- Oxygen
- Radium

(You don't need a firmware download for the USB Audio Quattro, Duo, or
MidiSport 2x4.)
endef

define Build/Configure
	true
endef

define Build/Compile
	true
endef

define Package/midisport-firmware/install
	$(INSTALL_DIR) $(1)/usr/share/usb/maudio $(1)/etc/hotplug.d/usb
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/*.ihx $(1)/usr/share/usb/maudio
	$(INSTALL_DATA) ./files/midisport-firmware.hotplug $(1)/etc/hotplug.d/usb/50-midisport-firmware
endef

$(eval $(call BuildPackage,midisport-firmware))
