#
# Copyright (C) 2009-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ccid
PKG_VERSION:=1.4.24
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://alioth.debian.org/frs/download.php/file/4171
PKG_MD5SUM:=62cb73c6c009c9799c526f05a05e25f00f0ad86d50f82a714dedcfbf4a7e4176
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPL-2.1+
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=libtool
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ccid
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libusb-1.0 +libpcsclite
  TITLE:=Generic USB CCID smart card reader driver
  URL:=http://pcsclite.alioth.debian.org/ccid.html
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
