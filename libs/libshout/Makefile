#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libshout
PKG_VERSION:=2.4.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://downloads.xiph.org/releases/libshout/ \
		http://distcache.eu.freebsd.org/local-distfiles/sunpoet/
PKG_MD5SUM:=f3acb8dec26f2dbf6df778888e0e429a4ce9378a9d461b02a7ccbf2991bbf24d

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
  TITLE+= (no theora)
  VARIANT:=notheora
endef

define Package/libshout-full
  $(call Package/libshout/default)
  TITLE+= (all codecs)
  DEPENDS+= +libtheora
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
	--enable-static \
	--disable-speex \
	--without-openssl

ifeq ($(BUILD_VARIANT),notheora)
  CONFIGURE_ARGS += --disable-theora
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
