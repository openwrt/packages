#
# Copyright (C) 2007-2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=glib2
PKG_VERSION:=2.74.7
PKG_RELEASE:=2

PKG_SOURCE:=glib-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/glib/$(basename $(PKG_VERSION))
PKG_HASH:=196ab86c27127a61b7a70c3ba6af7b97bdc01c07cd3b21abd5e778b955eccb1b

PKG_MAINTAINER:=Peter Wagner <tripolar@gmx.at>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:gnome:glib

PKG_BUILD_DIR:=$(BUILD_DIR)/glib-$(PKG_VERSION)
PKG_CONFIG_DEPENDS:=CONFIG_BUILD_NLS
PKG_FORTIFY_SOURCE:=0
PKG_BUILD_FLAGS:=gc-sections

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/glib-$(PKG_VERSION)
HOST_BUILD_DEPENDS:=pcre2/host libffi/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/glib2/default
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=http://www.gtk.org/
endef

define Package/glib2-core
$(call Package/glib2/default)
  TITLE:=GLib 2.0 core library
  DEPENDS:=$(ICONV_DEPENDS) $(INTL_DEPENDS) +libattr +libpcre2
endef

define Package/glib2-gmodule
$(call Package/glib2/default)
  TITLE:=GLib 2.0 gmodule library
  DEPENDS:=+glib2-core
endef

define Package/glib2-gthread
$(call Package/glib2/default)
  TITLE:=GLib 2.0 gthread library
  DEPENDS:=+glib2-core
endef

define Package/glib2-gobject
$(call Package/glib2/default)
  TITLE:=GLib 2.0 gobject library
  DEPENDS:=+glib2-core +libffi
endef

define Package/glib2-gio
$(call Package/glib2/default)
  TITLE:=GLib 2.0 gio library
  DEPENDS:=+glib2-core +glib2-gobject +glib2-gmodule +zlib +libffi
endef

define Package/glib2
$(call Package/glib2/default)
  TITLE:=Full GLib 2.0 library
  DEPENDS:+glib2-gthread +glib2-gio
endef

define Package/glib2-core/description
  Common code and core library for GLib library of C routines
endef

define Package/glib2-gmodule/description
  GLib library module functions
endef

define Package/glib2-gthread/description
  GLib library thread functions
endef

define Package/glib2-gobject/description
  GLib library object functions
endef

define Package/glib2-gio/description
  GLib library io functions
endef

define Package/glib2/description
  The GLib library of C routines
endef

COMP_ARGS:=

# default feature=auto see meson_options.txt
COMP_ARGS+=-Dglib_debug=disabled

# default feature=auto see meson_options.txt
COMP_ARGS+=-Dlibmount=disabled

# default feature=auto see meson_options.txt
COMP_ARGS+=-Dselinux=disabled


# default boolean=false see meson_options.txt
COMP_ARGS+=-Dforce_posix_threads=true

# default boolean=true see meson_options.txt
COMP_ARGS+=-Dglib_assert=false

# default boolean=true see meson_options.txt
COMP_ARGS+=-Dtests=false


MESON_HOST_ARGS += $(COMP_ARGS) -Dxattr=false -Ddefault_library=static -Dnls=disabled -Dforce_fallback_for=libpcre2-8
MESON_ARGS += $(COMP_ARGS) -Dxattr=true -Db_lto=true -Ddefault_library=both -Dnls=$(if $(CONFIG_BUILD_NLS),en,dis)abled

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/* \
		$(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/glib-2.0 \
		$(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/glib-2.0/include/*.h \
		$(1)/usr/include/glib-2.0/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/gio-unix-2.0 \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/glib-2.0 \
		$(1)/usr/lib/

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.{so*,a} \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc \
		$(1)/usr/lib/pkgconfig

	$(INSTALL_DIR) $(2)/share/aclocal/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/share/aclocal/*.m4  \
		$(2)/share/aclocal/

	$(INSTALL_DIR) $(1)/usr/share/glib-2.0
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/share/glib-2.0/codegen \
		$(1)/usr/share/glib-2.0/
endef

define Package/glib2-core/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libglib-2.0.so* \
		$(1)/usr/lib/
endef

define Package/glib2-gmodule/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgmodule-2.0.so* \
		$(1)/usr/lib
endef

define Package/glib2-gthread/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgthread-2.0.so* \
		$(1)/usr/lib
endef

define Package/glib2-gobject/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgobject-2.0.so* \
		$(1)/usr/lib
endef

define Package/glib2-gio/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgio-2.0.so* \
		$(1)/usr/lib
endef

define Package/glib2/install
	:
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,glib2-core))
$(eval $(call BuildPackage,glib2-gmodule))
$(eval $(call BuildPackage,glib2-gthread))
$(eval $(call BuildPackage,glib2-gobject))
$(eval $(call BuildPackage,glib2-gio))
$(eval $(call BuildPackage,glib2))
