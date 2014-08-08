#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=audiofile
PKG_VERSION:=0.3.6
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:= \
	http://github.com/downloads/mpruett/audiofile/ \
	http://www.68k.org/~michael/audiofile/
PKG_MD5SUM:=2731d79bec0acef3d30d2fc86b0b72fd
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_FIXUP:=autoreconf
PKG_INSTALL=1

include $(INCLUDE_DIR)/package.mk

define Package/libaudiofile
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Audio File library
  URL:=http://www.68k.org/~michael/audiofile/
  DEPENDS:=+libflac +libstdcpp
endef

define Package/libaudiofile/description
 The audiofile library allows the processing of audio data to and from audio
 files of many common formats (currently AIFF, AIFF-C, WAVE, NeXT/Sun, BICS,
 FLAC, ALAC, and raw data).
endef

CONFIGURE_ARGS+= \
	--enable-shared \
	--enable-static \
	--disable-examples \
	--with-build-cc="$(HOSTCC)" \

TARGET_CFLAGS+= $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/{af_vfs,audiofile,aupvlist}.h \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libaudiofile.{la,a,so*} \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/audiofile.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libaudiofile/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libaudiofile.so.* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libaudiofile))
