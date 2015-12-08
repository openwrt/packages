#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libshout
PKG_VERSION:=2.3.1
PKG_RELEASE:=3

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://downloads.us.xiph.org/releases/libshout/
PKG_MD5SUM:=11765b2592e7ea623ccd93d3f8df172c

PKG_LICENSE:=LGPL-2.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libshout/default
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Shoutcast client library
  URL:=http://www.icecast.org/download.php
  DEPENDS:= +libvorbis +libvorbisidec +libpthread
endef

define Package/libshout
  $(call Package/libshout/default)
  TITLE+= (no speex & theora)
  VARIANT:=nospeex
endef

define Package/libshout-full
  $(call Package/libshout/default)
  TITLE+= (all codecs)
  DEPENDS+= +libspeex +libtheora
  VARIANT:=full
endef

define Package/libshout/description
 libshout allows applications to easily communicate and broadcast
 to an Icecast streaming media server. It handles the socket connections,
 metadata communication, and data streaming for the calling application,
 and lets developers focus on feature sets instead of implementation
 details.
endef

Package/libshout-full/description=Package/libshout/description

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static

ifeq ($(BUILD_VARIANT),nospeex)
  CONFIGURE_ARGS += --disable-theora --disable-speex
endif

CONFIGURE_VARS += \
	VORBIS_CFLAGS="-I$(STAGING_DIR)/usr/include/tremor/" \
	VORBIS_LIBS="$(TARGET_LDFLAGS) -lvorbis -lvorbisidec" \

TARGET_CFLAGS += $(FPIC) -Wl,-rpath-link="$(STAGING_DIR)/usr/lib"

PACKAGE_CONFIG_FILE=shout$(if $(findstring $(BUILD_VARIANT),full),-full).pc

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/shout $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libshout.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/shout.pc $(1)/usr/lib/pkgconfig/$(PACKAGE_CONFIG_FILE)
	$(SED) 's| -I/usr/include||' $(1)/usr/lib/pkgconfig/$(PACKAGE_CONFIG_FILE)
endef

define Package/libshout/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libshout.so.* $(1)/usr/lib/
endef
Package/libshout-full/install=$(Package/libshout/install)

$(eval $(call BuildPackage,libshout))
$(eval $(call BuildPackage,libshout-full))
