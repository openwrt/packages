#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=madplay
PKG_VERSION:=0.15.2b
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/mad \
	ftp://ftp.mars.org/pub/mpeg/
PKG_MD5SUM:=6814b47ceaa99880c754c5195aa1aac1
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Simon Peter <probono@puredarwin.org>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/madplay
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+libid3tag +libmad
  TITLE:=MPEG audio player in fixed point
  URL:=http://sourceforge.net/projects/mad
endef

define Package/madplay/description
	MAD is an MPEG audio decoder. It currently only supports the MPEG 1
	standard, but fully implements all three audio layers (Layer I, Layer II,
	and Layer III, the latter often colloquially known as MP3.). There is also
	full support for ID3 tags.
endef

define Build/Configure
	$(call Build/Configure/Default, \
		--enable-shared \
		--disable-static \
		--disable-debugging \
		--disable-profiling \
		--disable-experimental \
		--without-libiconv-prefix \
		--without-libintl-prefix \
		--without-alsa \
		--without-esd \
		, \
		LIBS="-lz" \
	)
endef

define Package/madplay/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/madplay $(1)/usr/bin/
endef

$(eval $(call BuildPackage,madplay))
