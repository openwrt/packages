# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=cairo
PKG_VERSION:=1.16.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://cairographics.org/releases/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=5e7b29b3f113ef870d1e3ecf8adf21f923396401604bda16d44be45e66052331

#PKG_BUILD_DEPENDS:=
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
#PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/cairo
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libxrender +pixman +libxext +libpng +glib2 \
	    +libfreetype +xcb-util +fontconfig +zlib
  TITLE:=A vector graphics library
  URL:=https://cairographics.org/
endef

#TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed
TARGET_LDFLAGS += -Wl,--as-needed

MAKE_FLAGS+= \
  --output-sync=target

CONFIGURE_ARGS += \
  --prefix=/usr \
  --enable-ft \
  --enable-pdf \
  --enable-png \
  --enable-ps \
  --enable-svg \
  --enable-tee \
  --enable-x \
  --enable-xcb \
  --enable-xcb-shm \
  --enable-xlib \
  --enable-xlib-xrender \
  --disable-xlib-xcb \
  --disable-trace \
  --enable-static=no

define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib \

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include/* \
	  $(1)/usr/include/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
	  $(1)/usr/lib/
endef

define Package/cairo/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
	  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,cairo))
