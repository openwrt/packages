#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=audiofile
PKG_VERSION:=0.2.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:= \
	http://github.com/downloads/mpruett/audiofile/ \
	http://www.68k.org/~michael/audiofile/
PKG_MD5SUM:=a39be317a7b1971b408805dc5e371862

PKG_FIXUP:=autoreconf
PKG_INSTALL=1

include $(INCLUDE_DIR)/package.mk

define Package/libaudiofile
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Audio File library
  URL:=http://www.68k.org/~michael/audiofile/
endef

define Package/libaudiofile/description
 The audiofile library allows the processing of audio data to and from audio
 files of many common formats (currently AIFF, AIFF-C, WAVE, NeXT/Sun, BICS,
 and raw data).
endef

CONFIGURE_ARGS+= \
	--enable-shared \
	--enable-static \
	--with-build-cc="$(HOSTCC)" \

TARGET_CFLAGS+= $(FPIC) -std=c99

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/audiofile-config \
		$(2)/bin/
	$(SED) \
		's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' \
		$(2)/bin/audiofile-config

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
