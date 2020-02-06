#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=madplay
PKG_VERSION:=0.15.2b
PKG_RELEASE:=7

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/mad \
	ftp://ftp.mars.org/pub/mpeg/
PKG_HASH:=5a79c7516ff7560dffc6a14399a389432bc619c905b13d3b73da22fa65acede0

PKG_MAINTAINER:=Simon Peter <probono@puredarwin.org>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/madplay/default
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+libid3tag +libmad $(INTL_DEPENDS) $(2)
  TITLE:=MPEG audio player in fixed point - $(1)
  VARIANT:=$(1)
  URL:=http://sourceforge.net/projects/mad
endef

Package/madplay-alsa=$(call Package/madplay/default,alsa,+alsa-lib)
Package/madplay=$(call Package/madplay/default,oss)

define Package/madplay/description
	MAD is an MPEG audio decoder. It currently only supports the MPEG 1
	standard, but fully implements all three audio layers (Layer I, Layer II,
	and Layer III, the latter often colloquially known as MP3.). There is also
	full support for ID3 tags.
endef

CONFIGURE_ARGS += \
	--enable-shared \
	--disable-static \
	--disable-debugging \
	--disable-profiling \
	--disable-experimental \
	--without-libiconv-prefix \
	--without-libintl-prefix \
	--without-esd \

CONFIGURE_VARS += \
	lt_prog_compiler_pic=$(FPIC)

MAKE_FLAGS += CFLAGS="$(TARGET_CFLAGS)"

ifeq ($(BUILD_VARIANT),alsa)
	CONFIGURE_ARGS += \
		--without-oss \
		--with-alsa
else
	CONFIGURE_ARGS += \
		--without-alsa \
		--with-oss
endif

define Package/madplay/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/madplay $(1)/usr/bin/
endef

define Package/madplay-alsa/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/madplay $(1)/usr/bin/
endef

$(eval $(call BuildPackage,madplay-alsa))
$(eval $(call BuildPackage,madplay))
