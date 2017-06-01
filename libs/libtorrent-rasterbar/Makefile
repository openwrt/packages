#
# Copyright (C) 2017 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtorrent-rasterbar
PKG_VERSION:=1.1.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Daniel Engberg <daniel.engberg.lists@pyret.net>
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=libtorrent-rasterbar-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL=https://github.com/arvidn/libtorrent/releases/download/libtorrent-1_1_1/
PKG_HASH:=f70c82367b0980460ef95aff3e117fd4a174477892d529beec434f74d615b31f

PKG_BUILD_PARALLEL:=0
PKG_USE_MIPS16:=0
PKG_INSTALL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/libtorrent-rasterbar
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+boost-chrono +boost-random +boost-system +libopenssl +libncursesw +libstdcpp
  TITLE:=libtorrent-rasterbar
  URL:=https://github.com/arvidn/libtorrent/
endef

define Package/libtorrent-rasterbar/description
  libtorrent is a feature complete C++ bittorrent implementation
  focusing on efficiency and scalability. It runs on embedded 
  devices as well as desktops.
endef

EXTRA_CXXFLAGS += -std=gnu++11 -Wno-deprecated-declarations
EXTRA_LDFLAGS+= -lstdc++

TARGET_CXX=$(TARGET_CC)

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--enable-dht \
	--enable-encryption \
	--enable-pool-allocators \
	--enable-deprecated-functions \
	--with-libiconv \
	--disable-python-binding \
	--with-boost=$(STAGING_DIR)/usr/include \
	--with-boost-libdir=$(STAGING_DIR)/usr/lib

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libtorrent $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtorrent-rasterbar.{a,so*} $(1)/usr/lib/
endef

define Package/libtorrent-rasterbar/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtorrent-rasterbar.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libtorrent-rasterbar))
