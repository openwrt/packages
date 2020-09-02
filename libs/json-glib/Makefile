#
# Copyright (C) 2020 Sebastian Kemper <sebastian_ml@gmx.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=json-glib
PKG_VERSION:=1.5.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/json-glib/1.5
PKG_HASH:=ad08438327b6106dc040c0581477bdf1cd3daaa5d285920cc768b8627f746666

PKG_INSTALL:=1

PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Sebastian Kemper <sebastian_ml@gmx.net>

PKG_BUILD_DEPENDS:=glib2/host meson/host

OPENWRT_VERBOSE:=c

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../../devel/meson/meson.mk

define Package/json-glib
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=JSON GLib Library
  URL:=https://wiki.gnome.org/Projects/JsonGlib
  DEPENDS:=+glib2
endef

define Package/json-glib/description
JSON-GLib is a library providing serialization and deserialization
support for the JavaScript Object Notation (JSON) format described by
RFC 4627.
endef

MESON_ARGS += \
	-Dintrospection=disabled \
	-Dgtk_doc=disabled \
	-Dman=false \
	-Dtests=false

# Disable installed-tests; this also indirectly removes
# build_aux/gen-installed-test.py calls (copied from Gentoo)
define Build/Prepare
	$(call Build/Prepare/Default)
	$(SED) 's/install: true/install: false/g' \
		$(PKG_BUILD_DIR)/json-glib/tests/meson.build
	$(SED) '/install_data/d' \
		$(PKG_BUILD_DIR)/json-glib/tests/meson.build
	$(SED) '/error=format=2/d' $(PKG_BUILD_DIR)/meson.build
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/json-glib-1.0/json-glib
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/json-glib-1.0/json-glib/*.h \
				$(1)/usr/include/json-glib-1.0/json-glib
	
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjson-glib-1.0.so* \
						$(1)/usr/lib
	
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/json-glib-1.0.pc \
					$(1)/usr/lib/pkgconfig
endef

define Package/json-glib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjson-glib-1.0.so.* \
						$(1)/usr/lib
endef

$(eval $(call BuildPackage,json-glib))
