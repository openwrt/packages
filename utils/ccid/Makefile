#
# Copyright (C) 2009-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ccid
PKG_VERSION:=1.6.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://ccid.apdu.fr/files/
PKG_HASH:=41958410950157e622f9d91c9e78c7b708db74e22f71190c581d24d20564d449
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=libtool
PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=zlib

include $(INCLUDE_DIR)/package.mk

define Package/ccid
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libusb-1.0 +libpcsclite
  TITLE:=Generic USB CCID smart card reader driver
  URL:=https://ccid.apdu.fr/
endef

define Package/ccid/description
  Generic USB CCID (Chip/Smart Card Interface Devices) driver and ICCD
  (Integrated Circuit(s) Card Devices).
endef

TARGET_CFLAGS += $(FPIC)

TARGET_LDFLAGS += "-lpthread"

CONFIGURE_ARGS += \
	--enable-embedded \
	--enable-usbdropdir=/usr/lib/pcsc/drivers

define Package/ccid/install
	$(INSTALL_DIR) $(1)/usr/lib/pcsc
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pcsc/drivers $(1)/usr/lib/pcsc/
endef

$(eval $(call BuildPackage,ccid))
