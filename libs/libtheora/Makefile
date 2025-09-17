#
# Copyright (C) 2008-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtheora
PKG_VERSION:=1.2.0
PKG_RELEASE:=1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://downloads.xiph.org/releases/theora/
PKG_HASH:=ebdf77a8f5c0a8f7a9e42323844fa09502b34eb1d1fece7b5f54da41fe2122ec

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING LICENSE

PKG_FIXUP:=autoreconf
PKG_BUILD_DEPENDS:=libvorbis

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/libtheora
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libtheora
  URL:=http://xiph.org/theora/
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
  DEPENDS:=+libogg
endef

define Package/libtheora/description
Theora is Xiph.Org's first publicly released video codec, intended
for use within the Foundation's Ogg multimedia streaming system.
Theora is derived directly from On2's VP3 codec; Currently the
encoders are nearly identical, but Theora will make use of new
features supported by the decoder to improve over what is
is possible with VP3.
endef

CONFIGURE_ARGS += \
	--disable-examples \
	--disable-oggtest \
	--disable-vorbistest \
	--disable-sdltest

ifneq ($(findstring armeb,$(CONFIG_ARCH)),)
CONFIGURE_ARGS += --disable-asm
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/theora/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/theora/* $(1)/usr/include/theora/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{so*,a,la} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
endef

define Package/libtheora/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libtheora))
