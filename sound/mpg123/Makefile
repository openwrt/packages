#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mpg123
PKG_VERSION:=1.25.10
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/mpg123
PKG_HASH:=6c1337aee2e4bf993299851c70b7db11faec785303cfca3a5c3eb5f329ba7023
PKG_MAINTAINER:=Zoltan HERPAI <wigyori@uid0.hu>

PKG_FIXUP:=libtool

PKG_LICENSE:=LGPL-2.1 GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/mpg123/Default
  URL:=http://www.mpg123.de
endef

define Package/libmpg123
  $(call Package/mpg123/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=fast console mpeg audio decoder library
  DEPENDS:=+libltdl
endef

define Package/libout123
  $(call Package/mpg123/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for continuous playback of audio streams via various platform-specific output methods
  DEPENDS:=+libltdl
endef

define Package/mpg123
  $(call Package/mpg123/Default)
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=fast console mpeg audio player
  DEPENDS+=+libmpg123 +alsa-lib +libout123
endef

TARGET_CFLAGS += -D_GNU_SOURCE

CONFIGURE_ARGS+= \
	--enable-shared \
	--enable-static \
	--with-audio=alsa \
	--with-default-audio=alsa \

ifeq ($(CONFIG_SOFT_FLOAT),y)
	CONFIGURE_ARGS+= \
		--with-cpu=generic_nofpu \
		--enable-int-quality=yes
else
	CONFIGURE_ARGS+= \
		--with-cpu=generic_fpu
endif

ifneq ($(findstring neon,$(CONFIG_TARGET_OPTIMIZATION)),)
        CONFIGURE_ARGS+= \
                --with-cpu=arm_fpu
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/mpg123.h \
		$(PKG_INSTALL_DIR)/usr/include/out123.h \
		$(PKG_INSTALL_DIR)/usr/include/fmt123.h \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libmpg123.{la,a,so*} \
		$(PKG_INSTALL_DIR)/usr/lib/libout123.{la,a,so*} \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/mpg123
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/mpg123/* \
		$(1)/usr/lib/mpg123

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libmpg123.pc \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libout123.pc \
		$(1)/usr/lib/pkgconfig
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
$(eval $(call BuildPackage,mpg123))
