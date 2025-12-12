#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtorrent
PKG_VERSION:=0.15.5
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rakshasa/libtorrent
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=f5baa923bf45b84a2d1a8bc279815fc5d4f460e581e2d0e3070b97f134301378

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libtorrent
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Rakshasa's BitTorrent library
  URL:=https://rakshasa.github.io/rtorrent/
  DEPENDS:=+libopenssl +libstdcpp +zlib
  BUILDONLY:=1
endef

define Package/libtorrent/description
 LibTorrent is a BitTorrent library written in C++ for *nix, with a focus on
 high performance and good code. The library differentiates itself from other
 implementations by transferring directly from file pages to the network stack.
 On high-bandwidth connections it is able to seed at 3 times the speed of the
 official client.
endef

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--disable-aligned \
	--disable-debug \
	--disable-instrumentation \
	--with-epoll \
	--with-zlib=$(STAGING_DIR)/usr \
	--without-kqueue

CONFIGURE_VARS = \
	ax_cv_cxx_compile_cxx17=yes

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/torrent $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtorrent.a $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libtorrent.pc $(1)/usr/lib/pkgconfig/
endef

$(eval $(call BuildPackage,libtorrent))
