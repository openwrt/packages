#
# Copyright (C) 2016 Velocloud Inc.
# Copyright (C) 2016 Aleksander Morgado <aleksander@aleksander.es>
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libqrtr-glib
PKG_VERSION:=1.2.2
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.freedesktop.org/mobile-broadband/libqrtr-glib.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=483e17daa7ad17928d53a11fa3bed6201f3a94ce16cfd0b5bff39941de14d115

PKG_BUILD_FLAGS:=gc-sections

PKG_MAINTAINER:=Nicholas Smith <nicholas.smith@telcoantennas.com.au>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

TARGET_CFLAGS += -fno-merge-all-constants -fmerge-constants

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
	-Dgtk_doc=false \
	-Db_lto=true

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
