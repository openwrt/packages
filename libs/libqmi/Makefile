#
# Copyright (C) 2016 Velocloud Inc.
# Copyright (C) 2016 Aleksander Morgado <aleksander@aleksander.es>
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libqmi
PKG_SOURCE_VERSION:=1.32.4
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.freedesktop.org/mobile-broadband/libqmi.git
PKG_MIRROR_HASH:=674f5848c56c11cdc2fbc82c52e5bc2a3a0fddb56315dc4220544688a7b0e17a

PKG_BUILD_FLAGS:=gc-sections

PKG_MAINTAINER:=Nicholas Smith <nicholas@nbembedded.com>
PKG_CPE_ID:=cpe:/a:libqmi_project:libqmi

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

TARGET_CFLAGS += -fno-merge-all-constants -fmerge-constants

define Package/libqmi/config
  source "$(SOURCE)/Config.in"
endef

define Package/libqmi
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:= \
    +glib2 \
    +LIBQMI_WITH_MBIM_QMUX:libmbim \
    +LIBQMI_WITH_QRTR_GLIB:libqrtr-glib
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

MESON_ARGS += \
	-Dudev=false \
	-Dintrospection=false \
	-Dman=false \
	-Dbash_completion=false \
	-Db_lto=true \
	-Dmbim_qmux=$(if $(CONFIG_LIBQMI_WITH_MBIM_QMUX),true,false) \
	-Dqrtr=$(if $(CONFIG_LIBQMI_WITH_QRTR_GLIB),true,false) \
	-Dcollection=$(if $(CONFIG_LIBQMI_COLLECTION_MINIMAL),minimal\
		    ,$(if $(CONFIG_LIBQMI_COLLECTION_BASIC),basic,full))

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
	$(INSTALL_DIR) \
		$(1)/usr/lib \
		$(1)/usr/libexec

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libqmi*.so.* \
		$(1)/usr/lib/

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/libexec/qmi-proxy $(1)/usr/libexec/
endef

define Package/qmi-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/qmicli $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/qmi-network $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/qmi-firmware-update $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libqmi))
$(eval $(call BuildPackage,qmi-utils))
