#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=liblz4
PKG_VERSION:=1.9.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/lz4/lz4/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=658ba6191fa44c92280d4aa2c271b0f4fbc0e34d249578dd05e50e76d0e5efcc
PKG_BUILD_DIR:=$(BUILD_DIR)/lz4-$(PKG_VERSION)

PKG_MAINTAINER:=Darik Horn <dajhorn@vanadac.com>

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1
CMAKE_SOURCE_SUBDIR:=contrib/cmake_unofficial

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/lz4/Default
  SUBMENU:=Compression
  URL:=https://www.lz4.org/
endef

define Package/liblz4
$(call Package/lz4/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Extremely fast compression
  LICENSE:=BSD-2-Clause
  LICENSE_FILES:=LICENSE lib/LICENSE
  ABI_VERSION:=$(firstword $(subst .,$(space),$(PKG_VERSION)))
  MENU:=1
endef

define Package/liblz4/description
  LZ4 is a compression codec that features a very fast encoder and an
  even faster decoder. This package provides the liblz4 shared library.
endef

define Package/liblz4/config
	source "$(SOURCE)/Config.in"
endef

define Package/lz4
$(call Package/lz4/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Extremely fast compression
  LICENSE:=GPL-2.0-or-later
  LICENSE_FILES:=LICENSE programs/COPYING
  DEPENDS:=+liblz4
endef

define Package/lz4/description
  LZ4 - Fast real-time compression algorithm.
  This package provides the lz4 binaries.
endef

CMAKE_OPTIONS += \
	-DCMAKE_INSTALL_MANDIR=/dev/null \
	-DLZ4_BUILD_LEGACY_LZ4C=OFF

ifeq ($(CONFIG_LZ4_OPTIMIZE_SPEED),y)
	TARGET_CFLAGS := $(filter-out -O%,$(TARGET_CFLAGS)) -O3
endif

TARGET_CFLAGS += $(FPIC) -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections

define Package/liblz4/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblz4.so.$(ABI_VERSION)* $(1)/usr/lib/
endef

define Package/lz4/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/{lz4,lz4cat,unlz4} $(1)/usr/bin/
endef

$(eval $(call BuildPackage,liblz4))
$(eval $(call BuildPackage,lz4))
