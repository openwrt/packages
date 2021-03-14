#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=taglib
PKG_VERSION:=1.12-beta-2
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/taglib/taglib/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=e273e9d97592cebd4e84e71313e91e9df0fc4a8e00c35daea62325e8bebb87d9

PKG_MAINTAINER:=
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING.LGPL
PKG_CPE_ID:=cpe:/a:taglib:taglib

include $(INCLUDE_DIR)/package.mk
include ../../devel/ninja/ninja-cmake.mk

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
	-DBUILD_TESTS=OFF \
	-DBUILD_EXAMPLES=OFF \
	-DBUILD_BINDINGS=OFF \
	-DNO_ITUNES_HACKS=ON

TARGET_CXXFLAGS += -flto

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) '/^prefix=\|^exec_prefix=/s|/usr|$(STAGING_DIR)/usr|' $(1)/usr/bin/taglib-config
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/taglib.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/taglib.pc
	$(INSTALL_DIR) $(2)/bin
	$(LN) ../../usr/bin/taglib-config $(2)/bin/taglib-config
endef

$(eval $(call BuildPackage,taglib))
