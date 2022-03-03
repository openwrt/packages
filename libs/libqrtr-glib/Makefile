#
# Copyright (C) 2016 Velocloud Inc.
# Copyright (C) 2016 Aleksander Morgado <aleksander@aleksander.es>
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libqrtr-glib
PKG_VERSION:=1.2.2
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.freedesktop.org/mobile-broadband/libqrtr-glib.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=ffb918edf96581d4ba310bd1e975297e9a7006a7e26f37934afde462585125f2

PKG_MAINTAINER:=Nicholas Smith <nicholas.smith@telcoantennas.com.au>

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libqrtr-glib
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+glib2
  TITLE:=Helper library to talk to QRTR enabled modems
  URL:=https://gitlab.freedesktop.org/mobile-broadband/libqrtr-glib
  LICENSE:=LGPL-2.1-or-later
  LICENSE_FILES:=COPYING.LIB
endef

define Package/libqrtr-glib/description
  Helper library talk to QRTR enabled modems.
endef

MESON_ARGS += \
	-Dintrospection=false \
	-Dgtk_doc=false

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/libqrtr-glib \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libqrtr-glib*.so* \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/qrtr-glib.pc \
		$(1)/usr/lib/pkgconfig
endef

define Package/libqrtr-glib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libqrtr-glib*.so.* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libqrtr-glib))
