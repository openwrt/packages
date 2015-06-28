#
# Copyright (C) 2010-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

LOWFAT_VERSION=0.30

PKG_NAME:=libowfat
PKG_VERSION:=$(LOWFAT_VERSION)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://www.fefe.de/libowfat
PKG_MD5SUM:=f0119532ea834ce9e80afe49d7d85512
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

# set to 1 to enable debugging
DEBUG=

define Package/libowfat
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=reimplemented libdjb under GPL
  URL:=http://www.fefe.de/libowfat/
endef

define Build/Configure
endef

TARGET_CFLAGS += $(FPIC)
LOWFAT_MAKEOPTS = $(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS) -I$(PKG_BUILD_DIR) -I$(STAGING_DIR)/usr/include" \
	DEBUG="$(DEBUG)" \
	VERSION="$(LOWFAT_VERSION)" \
	OS="Linux"

# work around a nasty gcc bug
ifneq ($(CONFIG_GCC_VERSION_4_2_4),)
  LOWFAT_MAKEOPTS += WOPTS=""
endif

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(LOWFAT_MAKEOPTS)
endef

define Build/InstallDev
	mkdir -p $(1)/usr/include/libowfat
	$(CP) $(PKG_BUILD_DIR)/*.h $(1)/usr/include/libowfat
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/*.a $(1)/usr/lib
endef

$(eval $(call BuildPackage,libowfat))
