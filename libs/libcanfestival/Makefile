#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libcanfestival
PKG_RELEASE:=4

PKG_SOURCE_PROTO:=hg
PKG_SOURCE_URL:=http://dev.automforge.net/CanFestival-3
PKG_SOURCE_DATE:=2015-08-03
PKG_SOURCE_VERSION:=8bfe0ac00cdb
PKG_MIRROR_HASH:=6d83e128302956bf654268ed8ee75aa1461f14dc6e566e52966a874564dc4ec5

PKG_MAINTAINER:=Anton Glukhov <anton.a.glukhov@gmail.com>

PKG_LICENSE:=LGPL-2.1+
PKG_LICENSE_FILES:=LICENCE

TAR_OPTIONS+= -m
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libcanfestival
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Free software CANopen library
  URL:=http://canfestival.org
  DEPENDS:=+libpthread +librt
endef

define Package/libcanfestival/description
  CanFestival library
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS := \
	--cc=$(TARGET_CC) \
	--cxx=$(TARGET_CXX) \
	--ld=$(TARGET_CC) \
	--arch=$(ARCH) \
	--binutils=$(TARGET_CROSS) \
	--os=Linux \
	--kerneldir=$(LINUX_DIR) \
	--prefix=/usr \
	--target=unix \
	--can=socket \
	--timers=unix \
	--debug=ERR \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Package/libcanfestival/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcanfestival_can_socket.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libcanfestival))
