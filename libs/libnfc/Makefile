#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libnfc
PKG_VERSION:=1.7.1
PKG_RELEASE:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://code.google.com/p/libnfc/
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=LGPL-2.1
PKG_MAINTAINER:=Sebastian Wendel <packages@sourceindex.de>

include $(INCLUDE_DIR)/package.mk

define Package/libnfc/Default
	TITLE:=A open source library for Near Field Communication (NFC)
	URL:=http://nfc-tools.org/
endef

define Package/libnfc
	$(call Package/libnfc/Default)
	SECTION:=libs
	CATEGORY:=Libraries
	DEPENDS:=+libusb-compat +pcscd +ccid
endef

define Package/libnfc/description
	libnfc is the first libre, platform-independent, low level NFC SDK and Programmers API

	* manipulate Jewel Topaz tags using libnfc
	* manipulate MIFARE Classic and Ultralight tags using libnfc

endef

define Package/nfc-utils
	$(call Package/libnfc/Default)
	SECTION:=utils
	CATEGORY:=Utilities
	DEPENDS:=+libnfc
endef

define Package/nfc-utils/description
	Provide some examples shared functions like print, parity calculation, options parsing

	* Emulates a NFC Forum Tag Type 4 v2.0 (or v1.0)
	* Jewel dump/restore tool
	* Lists the first target present of each founded device
	* MIFARE Classic manipulation example
	* MIFARE Ultralight dump/restore tool
	* Extract NDEF Message from a NFC Forum Tag Type 3
	* Relay example using two PN532 devices
	* Lists each available NFC device

endef

TARGET_CFLAGS+=$(FPIC)
CONFIGURE_ARGS+=--without-readline

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/nfc $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnfc.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libnfc.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libnfc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnfc.so.* $(1)/usr/lib/
endef

define Package/nfc-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/nfc-emulate-forum-tag4 $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/nfc-jewel $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/nfc-list $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/nfc-mfclassic $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/nfc-mfultralight $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/nfc-read-forum-tag3 $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/nfc-relay-picc $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/nfc-scan-device $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libnfc))
$(eval $(call BuildPackage,nfc-utils))
