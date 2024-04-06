#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=taglib
PKG_VERSION:=2.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/taglib/taglib
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=de161820f5a5d3e0e0fb8f04fdae8c8a094897d1418e33b39ca634d4c538ecd0

PKG_MAINTAINER:=
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING.LGPL
PKG_CPE_ID:=cpe:/a:taglib:taglib

PKG_BUILD_FLAGS:=lto

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/taglib
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=taglib
  URL:=https://github.com/taglib/taglib
  DEPENDS:=+zlib +libstdcpp
endef

define Package/taglib/description
  TagLib is a library for reading and editing the metadata of several
  popular audio formats. Currently it supports both ID3v1 and ID3v2 for
  MP3 files, Ogg Vorbis comments and ID3 tags in FLAC, MPC, Speex, WavPack,
  TrueAudio, WAV, AIFF, MP4, APE, DSF, DFF, and ASF files.
endef

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON
	-DBUILD_TESTS=OFF \
	-DBUILD_EXAMPLES=OFF \
	-DBUILD_BINDINGS=OFF \
	-DNO_ITUNES_HACKS=ON

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) '/^prefix=\|^exec_prefix=/s|/usr|$(STAGING_DIR)/usr|' $(1)/usr/bin/taglib-config
	$(SED) '/^includedir=/s|/usr|$(STAGING_DIR)/usr|' $(1)/usr/bin/taglib-config
	$(SED) '/^libdir=/s|/usr|$(STAGING_DIR)/usr|' $(1)/usr/bin/taglib-config
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/taglib.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/taglib.pc
	$(INSTALL_DIR) $(2)/bin
	$(LN) ../../usr/bin/taglib-config $(2)/bin/taglib-config
endef

define Package/taglib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtag.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,taglib))
