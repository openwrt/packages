#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=portaudio
PKG_VERSION:=19.7.0
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/PortAudio/portaudio
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=ddfa5d2a9a26d3337d337231c3403497373dfb1259a9ac7a6810db1e6c529f08

PKG_MAINTAINER:=
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/portaudio
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+alsa-lib
  TITLE:=Portable cross-platform audio I/O
  URL:=https://www.portaudio.com/
endef

define Package/portaudio/description
 PortAudio is a free, cross-platform, open-source, audio I/O library.  It lets
 you write simple audio programs in 'C' or C++ that will compile and run on many
 platforms including Windows, Macintosh OS X, and Unix (OSS/ALSA). It is
 intended to promote the exchange of audio software between developers on
 different platforms. Many applications use PortAudio for Audio I/O.
endef

define Package/portaudio/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libportaudio.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,portaudio))
