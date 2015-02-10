#
# Copyright (C) 2007-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtorrent
PKG_VERSION:=0.13.4-git-0
PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rakshasa/libtorrent.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=72e908707f01ee01a9b4918436c64348878b63f7
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libtorrent
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Rakshasa's BitTorrent library
  URL:=http://libtorrent.rakshasa.no/
  DEPENDS:=+libopenssl +libsigcxx
  MAINTAINER:=Peter Wagner <tripolar@gmx.at>
endef

define Package/libtorrent/description
 LibTorrent is a BitTorrent library written in C++ for *nix, with a focus on
 high performance and good code. The library differentiates itself from other
 implementations by transfering directly from file pages to the network stack.
 On high-bandwidth connections it is able to seed at 3 times the speed of the
 official client.
endef

TARGET_LDFLAGS += $(LIBGCC_S)

CONFIGURE_ARGS+= \
	--enable-shared \
	--enable-static \
	--enable-aligned \
	--disable-debug \
	--enable-openssl \
	--disable-instrumentation \
	--with-zlib=$(STAGING_DIR)/usr

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/torrent $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtorrent.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libtorrent.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libtorrent/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtorrent.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libtorrent))
