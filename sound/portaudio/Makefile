#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=portaudio
PKG_VERSION:=19_20140130
PKG_RELEASE:=2

PKG_SOURCE:=pa_stable_v$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://www.portaudio.com/archives/
PKG_HASH:=8fe024a5f0681e112c6979808f684c3516061cc51d3acc0b726af98fc96c8d57

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/portaudio
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+alsa-lib +libpthread +librt
  TITLE:=Portable cross-platform audio I/O
  URL:=http://www.portaudio.com/
endef

define Package/portaudio/description
 PortAudio is a free, cross-platform, open-source, audio I/O library.  It lets
 you write simple audio programs in 'C' or C++ that will compile and run on many
 platforms including Windows, Macintosh OS X, and Unix (OSS/ALSA). It is
 intended to promote the exchange of audio software between developers on
 different platforms. Many applications use PortAudio for Audio I/O.
endef

CONFIGURE_ARGS+= \
	--with-alsa \
	--without-asihpi \
	--without-jack \
	--with-oss \

EXTRA_CFLAGS += $(TARGET_CPPFLAGS)

define Build/Compile
	$(call Build/Compile/Default,lib/libportaudio.la)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/portaudio.h \
		$(PKG_INSTALL_DIR)/usr/include/pa_linux_alsa.h \
		$(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libportaudio.{a,so*} \
		$(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/portaudio-*.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/portaudio/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libportaudio.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,portaudio))
