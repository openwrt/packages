#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=taglib
PKG_VERSION:=1.11.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/taglib/taglib/releases/download/v$(PKG_VERSION)
PKG_HASH:=b6d1a5a610aae6ff39d93de5efd0fdc787aa9e9dc1e7026fa4c961b26563526b

PKG_MAINTAINER:=
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING.LGPL

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/taglib
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=taglib
  URL:=https://github.com/taglib/taglib
  DEPENDS:=+libstdcpp
  BUILDONLY:=1
endef

define Package/taglib/description
  TagLib is a library for reading and editing the metadata of several
  popular audio formats. Currently it supports both ID3v1 and ID3v2 for
  MP3 files, Ogg Vorbis comments and ID3 tags in FLAC, MPC, Speex, WavPack,
  TrueAudio, WAV, AIFF, MP4, APE, DSF, DFF, and ASF files.
endef

CMAKE_OPTIONS += \
	-DHAVE_BOOST_BYTESWAP=OFF \
	-DBUILD_TESTS=OFF \
	-DBUILD_EXAMPLES=OFF \
	-DBUILD_BINDINGS=OFF \
	-DNO_ITUNES_HACKS=ON

TARGET_CXXFLAGS += -flto

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) '/^prefix=\|^exec_prefix=/s|/usr|$(STAGING_DIR)/usr|' $(1)/usr/bin/taglib-config
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/bin/taglib-config
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/bin/taglib-config
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/taglib.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/taglib.pc
endef

$(eval $(call BuildPackage,taglib))
