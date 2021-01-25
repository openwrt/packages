#
# Copyright (C) 2016 Velocloud Inc.
# Copyright (C) 2016 Aleksander Morgado <aleksander@aleksander.es>
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libqmi
PKG_VERSION:=1.26.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.freedesktop.org/software/libqmi
PKG_HASH:=ef76dc95ab0a06321a1bd25e875489cba12c9f6611974ca0135cf067bb20c960

PKG_MAINTAINER:=Nicholas Smith <nicholas.smith@telcoantennas.com.au>

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/libqmi/config
  source "$(SOURCE)/Config.in"
endef

define Package/libqmi
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:= \
    +glib2 \
    +LIBQMI_WITH_MBIM_QMUX:libmbim
  TITLE:=Helper library to talk to QMI enabled modems
  URL:=https://www.freedesktop.org/wiki/Software/libqmi
  LICENSE:=LGPL-2.0-or-later
  LICENSE_FILES:=COPYING.LIB
endef

define Package/libqmi/description
  Helper library talk to QMI enabled modems.
  Add qmi-utils for extra utilities.
endef

define Package/qmi-utils
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libqmi
  TITLE:=Utilities to talk to QMI enabled modems
  URL:=https://www.freedesktop.org/wiki/Software/libqmi
  LICENSE:=GPL-2.0-or-later
  LICENSE_FILES:=COPYING
endef

define Package/libqmi-utils/description
  Utils to talk to QMI enabled modems
endef

CONFIGURE_ARGS += \
	--disable-static \
	--disable-gtk-doc \
	--disable-gtk-doc-html \
	--disable-gtk-doc-pdf \
	--disable-silent-rules \
	--enable-firmware-update \
	--$(if $(LIBQMI_WITH_MBIM_QMUX),en,dis)able-mbim-qmux \
	--enable-more-warnings=yes \
	--without-udev \
	--without-udev-base-dir

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/libqmi-glib \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libqmi*.so* \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/qmi-glib.pc \
		$(1)/usr/lib/pkgconfig
endef

define Package/libqmi/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libqmi*.so.* \
		$(1)/usr/lib/

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/qmi-proxy $(1)/usr/lib/
endef

define Package/qmi-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/qmicli $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/qmi-network $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/qmi-firmware-update $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libqmi))
$(eval $(call BuildPackage,qmi-utils))
