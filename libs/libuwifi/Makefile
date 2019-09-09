#
# Copyright (C) 2016 Bruno Randolf (br1@einfach.org)
#               2019 Nick Hainke (vincent@systemli.org)
#
#
include $(TOPDIR)/rules.mk

PKG_NAME:=libuwifi
PKG_VERSION:=2019-05-27
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/br101/libuwifi.git
PKG_SOURCE_VERSION:=bb92bc9b041a077488f2fa5a1716902c7bb23e5b
PKG_MIRROR_HASH:=c6dc795ef6c2cc87d411d3f907974f634a132c3e732db2597f96ff25a05faa05

PKG_MAINTAINER:=Bruno Randolf <br1@einfach.org>, Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=LGPL-3.0-only
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libuwifi
	SECTION:=libs
	CATEGORY:=Libraries
	DEPENDS:=+libradiotap +libnl-tiny
	TITLE:=Userspace Wifi Library
endef

define Package/libuwifi/description
	Library for parsing, generating and analyzing Wifi (WLAN 802.11) frames in userspace and related functions.
endef

MAKE_FLAGS += DEBUG=0 LIBNL=tiny BUILD_RADIOTAP=0

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/uwifi

	$(CP) $(PKG_BUILD_DIR)/include/uwifi/*.h $(1)/usr/include/uwifi
	$(CP) $(PKG_BUILD_DIR)/linux/*.h $(1)/usr/include/uwifi

	$(CP) $(PKG_BUILD_DIR)/ccan $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/config.h $(1)/usr/include/ccan/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/build/libuwifi.{a,so*} $(1)/usr/lib/
endef

define Package/libuwifi/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/build/libuwifi.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libuwifi))
