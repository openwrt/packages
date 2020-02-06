#
# Copyright (C) 2016 Bruno Randolf (br1@einfach.org)
#               2019 Nick Hainke (vincent@systemli.org)
#
#
include $(TOPDIR)/rules.mk

PKG_NAME:=libuwifi
PKG_VERSION:=2019-12-05
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/br101/libuwifi.git
PKG_SOURCE_VERSION:=089bfebd3a8da6e39fd93e33c44368b044c23dde
PKG_MIRROR_HASH:=a99801ad1dfcf459b00adc582d5e6a31dae9ed10529d114e1e26f5760c6a74f8

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

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/build/libuwifi.{a,so*} $(1)/usr/lib/
endef

define Package/libuwifi/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/build/libuwifi.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libuwifi))
