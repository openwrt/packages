#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mpg123
PKG_VERSION:=1.26.3
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/mpg123
PKG_HASH:=30c998785a898f2846deefc4d17d6e4683a5a550b7eacf6ea506e30a7a736c6e

PKG_MAINTAINER:=Zoltan HERPAI <wigyori@uid0.hu>
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:mpg123:mpg123

PKG_BUILD_PARALLEL:=1
CMAKE_SOURCE_SUBDIR:=ports/cmake

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/mpg123/Default
  URL:=http://www.mpg123.de
endef

define Package/libmpg123
  $(call Package/mpg123/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=fast console mpeg audio decoder library
  LICENSE:=LGPL-2.1-or-later
  DEPENDS:=+libltdl
endef

define Package/libout123
  $(call Package/mpg123/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for continuous playback of audio streams via various platform-specific output methods
  LICENSE:=LGPL-2.1-or-later
  DEPENDS:=+libltdl
endef

define Package/libsyn123
  $(call Package/mpg123/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for signal generation and format conversion
  LICENSE:=LGPL-2.1-or-later
  DEPENDS:=+libltdl
endef

define Package/mpg123
  $(call Package/mpg123/Default)
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=fast console mpeg audio player
  LICENSE:=GPL-2.0-or-later
  DEPENDS+=+libmpg123 +alsa-lib +libout123 +libsyn123
endef

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DNO_FEATURE_REPORT=ON \
	-DNO_LFS_ALIAS=ON

ifeq ($(CONFIG_SOFT_FLOAT),y)
	CMAKE_OPTIONS += \
		-DPLATFORM_DEFINITIONS="OPT_GENERIC" \
		-DACCURATE_ROUNDING=OFF
else ifneq ($(findstring neon,$(CONFIG_CPU_TYPE)),)
	CMAKE_OPTIONS += \
		-DPLATFORM_DEFINITIONS="OPT_MULTI OPT_GENERIC OPT_GENERIC_DITHER OPT_NEON"
else ifneq ($(findstring aarch64,$(CONFIG_ARCH)),)
	CMAKE_OPTIONS += \
		-DPLATFORM_DEFINITIONS="OPT_MULTI OPT_GENERIC OPT_GENERIC_DITHER OPT_NEON64"
else
	CMAKE_OPTIONS += \
		-DPLATFORM_DEFINITIONS="OPT_GENERIC"
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/src/libmpg123/fmt123.h \
		$(PKG_INSTALL_DIR)/usr/include/mpg123.h \
		$(PKG_INSTALL_DIR)/usr/include/out123.h \
		$(PKG_INSTALL_DIR)/usr/include/syn123.h \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libmpg123.so \
		$(PKG_INSTALL_DIR)/usr/lib/libout123.so \
		$(PKG_INSTALL_DIR)/usr/lib/libsyn123.so \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/cmake/mpg123
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/cmake/mpg123/mpg123-config.cmake \
		$(PKG_INSTALL_DIR)/usr/lib/cmake/mpg123/mpg123-config-version.cmake \
		$(PKG_INSTALL_DIR)/usr/lib/cmake/mpg123/targets.cmake \
		$(PKG_INSTALL_DIR)/usr/lib/cmake/mpg123/targets-release.cmake \
		$(1)/usr/lib/cmake/mpg123

	$(INSTALL_DIR) $(1)/usr/lib/mpg123
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/mpg123/output_alsa.so \
		$(1)/usr/lib/mpg123

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libmpg123.pc \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libout123.pc \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libsyn123.pc \
		$(1)/usr/lib/pkgconfig
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/libmpg123.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/libmpg123.pc
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/libout123.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/libout123.pc
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/libsyn123.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/libsyn123.pc
endef

define Package/libmpg123/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libmpg123.so* \
		$(1)/usr/lib/
endef

define Package/libout123/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libout123.so* \
		$(1)/usr/lib/
endef

define Package/libsyn123/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libsyn123.so* \
		$(1)/usr/lib/
endef

define Package/mpg123/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/mpg123{,-id3dump,-strip} \
		$(PKG_INSTALL_DIR)/usr/bin/out123 \
		$(1)/usr/bin

	$(INSTALL_DIR) $(1)/usr/lib/mpg123
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/mpg123/* \
		$(1)/usr/lib/mpg123
endef

$(eval $(call BuildPackage,libmpg123))
$(eval $(call BuildPackage,libout123))
$(eval $(call BuildPackage,libsyn123))
$(eval $(call BuildPackage,mpg123))
