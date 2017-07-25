#
# Copyright (C) 2006-2012 OpenWrt.org
# Copyright (C) 2017      Leonardo Medici
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gphoto2
<<<<<<< HEAD
PKG_VERSION:=2.5.11
=======
PKG_VERSION:=2.5.14
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
PKG_RELEASE:=1
PKG_MAINTAINER:=Leonardo Medici <leonardo_medici@me.com>


PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/gphoto
<<<<<<< HEAD
PKG_MD5SUM:=a62a51474a681aca51b087905deb5e35
PKG_HASH:=392844d6a06512b0d85e7983a5a0c85c8039feb6ab3bc420674ffdbf7536f9e9
=======
PKG_MD5SUM:=6c6a21b5e879330cdd71ef92dce36399
PKG_HASH:=9302d02fb472d4936988382b7277ccdc4edaf7ede56c490278912ffd0627699c
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/gphoto2
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=Gphoto Digital Camera Control
  URL:=http://www.gphoto.org/
  DEPENDS:=+libgphoto2 +libpopt +libpthread +libreadline +libncurses +libexif +libjpeg
endef

define Package/gphoto2/description
 For downloading and controlling digital cameras
endef

CONFIGURE_ARGS += \
	--without-aalib \
	--without-libiconv-prefix \
	--without-libintl-prefix \

CONFIGURE_VARS += \
	LIBGPHOTO2_CFLAGS="$$$$CFLAGS -I$(STAGING_DIR)/usr/include/gphoto2 $$$$CPPFLAGS" \
	LIBGPHOTO2_LIBS="$$$$LDFLAGS -lgphoto2 -lgphoto2_port -lltdl" \
	LIBEXIF_CFLAGS="$$$$CFLAGS $$$$CPPFLAGS" \
	LIBEXIF_LIBS="$$$$LDFLAGS -lexif" \
	POPT_CFLAGS="$$$$CFLAGS $$$$CPPFLAGS" \
	POPT_LIBS="$$$$LDFLAGS -lpopt" \

define Package/gphoto2/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/
endef

$(eval $(call BuildPackage,gphoto2))
