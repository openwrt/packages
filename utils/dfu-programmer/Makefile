include $(TOPDIR)/rules.mk

PKG_NAME:=dfu-programmer
PKG_VERSION:=1.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/$(PKG_NAME)/$(PKG_NAME)/releases/download/v$(PKG_VERSION)/
PKG_HASH:=844e469be559657bc52c9d9d03c30846acd11ffbb1ddd42438fa8af1d2b8587d

PKG_MAINTAINER:=Stefan Hellermann <stefan@the2masters.de>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
MAKE_PATH:=src

include $(INCLUDE_DIR)/package.mk

define Package/dfu-programmer
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Microcontroller programming
  TITLE:=USB programmer for Atmel microcontrollers
  URL:=https://github.com/dfu-programmer/dfu-programmer
  DEPENDS:=+libusb-1.0
endef

define Package/dfu-programmer/description
  dfu-programmer is a Device Firmware Update (DFU) based USB programmer
  for Atmel chips with a USB bootloader.
endef

define Package/dfu-programmer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/
endef

$(eval $(call BuildPackage,dfu-programmer))
