#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=avrdude
PKG_VERSION:=7.3
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/avrdudes/avrdude
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=6799ef4d73870a0d130a28047917f051d8edd2aeb11a7825f1c19e416e38f6b6

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/avrdude
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Microcontroller programming
  TITLE:=AVR Downloader/UploaDEr
  URL:=https://github.com/avrdudes/avrdude
  DEPENDS:=+libncurses +libreadline +libusb-1.0 +libftdi1 +libelf +libgpiod
endef

define Package/avrdude/description
 AVRDUDE is a full featured program for programming Atmel's AVR CPU's.
endef

CMAKE_OPTIONS += \
	-DHAVE_LIBUSB=OFF \
	-DHAVE_LIBFTDI=OFF \
	-DHAVE_LIBHIDAPI=OFF \
	-DHAVE_LIBSERIALPORT=OFF \
	-DHAVE_LINUXGPIO=ON

define Package/avrdude/conffiles
/etc/avrdude.conf
endef

define Package/avrdude/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/etc/avrdude.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/avrdude $(1)/usr/bin/
endef

$(eval $(call BuildPackage,avrdude))
