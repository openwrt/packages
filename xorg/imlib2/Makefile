# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=imlib2
PKG_VERSION:=1.5.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=@SF/enlightenment
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=fa4e57452b8843f4a70f70fd435c746ae2ace813250f8c65f977db5d7914baae

#PKG_BUILD_DIR:=$(BUILD_DIR)/$(_PKG_NAME)-$(PKG_VERSION)
#PKG_BUILD_DEPENDS:=
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/imlib2
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libtiff +giflib +libpng +libid3tag +libjpeg-turbo +zlib +libx11 \
	    +libfreetype +libxext +libxcb +libbz2
  TITLE:=Image manipulation library
  URL:=https://sourceforge.net/projects/enlightenment
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS += \
  --prefix=/usr \
  --sysconfdir=/etc/imlib2 \
  --x-libraries=/usr/lib \
  --disable-mmx \
  --disable-amd64 \
  --enable-visibility-hiding \
  --with-x \
  --with-bzip2 \
  --with-gif \
  --with-id3 \
  --with-jpeg \
  --with-png \
  --with-tiff \
  --with-zlib

define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib \
	  $(1)/usr/lib/imlib2/{filters,loaders}

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include/* \
	  $(1)/usr/include/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
	  $(1)/usr/lib/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/imlib2/filters/*.so* \
	  $(1)/usr/lib/imlib2/filters/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/imlib2/loaders/*.so* \
	  $(1)/usr/lib/imlib2/loaders/
endef

define Package/imlib2/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib \
	  $(1)/usr/lib/imlib2/{filters,loaders}

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
	  $(1)/usr/lib/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/imlib2/filters/*.so* \
	  $(1)/usr/lib/imlib2/filters/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/imlib2/loaders/*.so* \
	  $(1)/usr/lib/imlib2/loaders/
endef

$(eval $(call BuildPackage,imlib2))
