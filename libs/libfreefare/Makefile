#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libfreefare
PKG_VERSION:=0.4.x
PKG_RELEASE:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/nfc-tools/libfreefare.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=b710ba5abda8cb986af48e5c6141ccd60773f061

include $(INCLUDE_DIR)/package.mk

define Package/libfreefare/Default
	TITLE:=The libfreefare project provides a convenient API for MIFARE card manipulations.
	URL:=http://nfc-tools.org/
endef

define Package/libfreefare
	$(call Package/libfreefare/Default)
	SECTION:=libs
	CATEGORY:=Libraries
	DEPENDS:=+libusb-compat +pcscd +ccid +libnfc +libopenssl
endef

define Package/libfreefare/description
endef

define Package/libfreefare-utils
	$(call Package/libfreefare/Default)
	SECTION:=utils
	CATEGORY:=Utilities
	DEPENDS:=+libfreefare
endef

define Package/libfreefare-utils/description
endef

TARGET_CFLAGS+=$(FPIC)
CONFIGURE_ARGS+=--without-readline

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/freefare.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfreefare.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libfreefare.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libfreefare/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfreefare.so.* $(1)/usr/lib/
endef

define Package/libfreefare-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mifare-ultralight-info                   $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mifare-desfire-read-ndef                 $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mifare-desfire-ev1-configure-default-key $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mifare-desfire-access                    $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mifare-classic-read-ndef                 $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mifare-desfire-format                    $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mifare-desfire-ev1-configure-random-uid  $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mifare-desfire-info                      $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mifare-classic-write-ndef                $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mifare-desfire-write-ndef                $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mifare-classic-format                    $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mifare-desfire-ev1-configure-ats         $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mifare-desfire-create-ndef               $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libfreefare))
$(eval $(call BuildPackage,libfreefare-utils))
