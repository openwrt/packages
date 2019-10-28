# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=libfontenc
PKG_VERSION:=1.1.4
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.x.org/releases/individual/lib/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=2cfcce810ddd48f2e5dc658d28c1808e86dcf303eaff16728b9aa3dbc0092079

PKG_BUILD_DEPENDS:=util-macros xproto font-util
HOST_BUILD_DEPENDS:=xproto/host util-macros/host
HOST_BUILD_PARALLEL:=1
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/libfontenc
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+zlib
  TITLE:=X11 font encoding library
  URL:=http://xorg.freedesktop.org/
endef

define Package/libfontenc/description
    Libfontenc is a library which helps font libraries portably determine
    and deal with different encodings of fonts.
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS += \
  --disable-static \
  --enable-shared \
  --with-fontrootdir=/usr/share/fonts/X11 \
  --with-encodingsdir=/usr/share/fonts/encodings

HOST_CONFIGURE_ARGS += \
  --enable-static \
  --disable-shared

define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include/* \
	  $(1)/usr/include/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
	  $(1)/usr/lib/
endef

define Package/libfontenc/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
	  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libfontenc))
$(eval $(call HostBuild))
