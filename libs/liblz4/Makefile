#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

# Although liblz4 exports a major.minor.patch version, it isn't always
# incremented for new releases. Check the NEWS file and instead use a
# release tag when appropriate. (eg: PKG_VERSION:=r131)
PKG_NAME:=liblz4
PKG_VERSION:=v1.7.5
PKG_RELEASE:=1

PKG_LICENSE:=BSD-2-Clause
PKG_MAINTAINER:=Darik Horn <dajhorn@vanadac.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=afb362b970816e06dac4997d26dd7d2cdb83168510228d174d25b1044b271e18
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/lz4/lz4.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/liblz4
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=Extremely fast compression
	URL:=http://www.lz4.org/
endef

define Package/liblz4/description
  LZ4 is a compression codec that features a very fast encoder and an
  even faster decoder. This package provides the liblz4 shared library.
endef

TARGET_CFLAGS += $(FPIC)

define Build/Compile
	$(MAKE) -C "$(PKG_BUILD_DIR)/lib" $(MAKE_INSTALL_FLAGS) \
	  CC="$(TARGET_CC)" \
	  CFLAGS="$(TARGET_CFLAGS)" \
	  PREFIX="$(CONFIGURE_PREFIX)" \
	  install
endef

define Build/InstallDev
	$(CP) $(PKG_INSTALL_DIR)/* $(1)/
endef

define Package/liblz4/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblz4.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,liblz4))
