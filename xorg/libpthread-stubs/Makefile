# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=libpthread-stubs
PKG_VERSION:=0.3
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://xcb.freedesktop.org/dist/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=35b6d54e3cc6f3ba28061da81af64b9a92b7b757319098172488a660e3d87299

##PKG_BUILD_DEPENDS:=util-macros
PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libpthread-stubs
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=
  TITLE:=Pthread functions stubs for platforms missing them
  URL:=http://cgit.freedesktop.org/xcb/pthread-stubs
endef

#### TARGET_CFLAGS += -DHAVE_PTHREAD_EXIT=1

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS += \
  --prefix=/usr \


define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/pkgconfig \
	  $(1)/usr/lib/
endef

#define Package/libpthread-stubs/install
#	$(INSTALL_DIR) \
#	  $(1)/usr/lib
#
#	$(CP) \
#	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
#	  $(1)/usr/lib/
#endef

$(eval $(call BuildPackage,libpthread-stubs))
