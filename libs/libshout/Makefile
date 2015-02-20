#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libshout
PKG_VERSION:=2.3.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://downloads.us.xiph.org/releases/libshout/
PKG_MD5SUM:=11765b2592e7ea623ccd93d3f8df172c

PKG_LICENSE:=LGPL-2.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libshout
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library which can be used to write a source client like ices
  URL:=http://www.icecast.org/download.php
  DEPENDS:= +libspeex +libtheora +libvorbis +libvorbisidec +libpthread
endef

define Package/libshout/description
 libshout allows applications to easily communicate and broadcast
 to an Icecast streaming media server. It handles the socket connections,
 metadata communication, and data streaming for the calling application,
 and lets developers focus on feature sets instead of implementation
 details.
endef

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \

CONFIGURE_VARS += \
	VORBIS_CFLAGS="-I$(STAGING_DIR)/usr/include/tremor/" \
	VORBIS_LIBS="$(TARGET_LDFLAGS) -lvorbis -lvorbisidec" \

TARGET_CFLAGS += $(FPIC) -Wl,-rpath-link="$(STAGING_DIR)/usr/lib"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/shout $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libshout.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/shout.pc $(1)/usr/lib/pkgconfig/
	$(SED) 's| -I/usr/include||' $(1)/usr/lib/pkgconfig/shout.pc
endef

define Package/libshout/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libshout.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libshout))
