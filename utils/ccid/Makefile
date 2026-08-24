#
# Copyright (C) 2009-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ccid
PKG_VERSION:=1.8.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://ccid.apdu.fr/files/
PKG_HASH:=d74294e23d436546c3e719c95a4da180b17f5e7ffdd36efca53f75351cb0de75
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=zlib

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

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

MESON_ARGS += \
	-Ddefault_library=shared \
	-Dembedded=true \
	-Dudev-rules=false

define Package/ccid/install
	$(INSTALL_DIR) $(1)/usr/lib/pcsc
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pcsc/drivers $(1)/usr/lib/pcsc/
endef

$(eval $(call BuildPackage,ccid))
