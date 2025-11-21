# SPDX-License-Identifier: GPL-3.0-or-later
#
# Copyright (C) 2024 qualIP Software.
# Released under the GPL v3.0 or later.

include $(TOPDIR)/rules.mk

PKG_NAME := static-device-names
PKG_VERSION := 1.0.0
PKG_RELEASE := 1

PKG_MAINTAINER := Jean-Sebastien Trottier <jst@qualipsoft.com>
PKG_LICENSE := GPL-3.0-or-later
PKG_LICENSE_FILES := LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/static-device-names
  SECTION := utils
  CATEGORY := Network
  TITLE := Support for static device names
  PKGARCH:=all
endef

define Package/static-device-names/description
  This package contains a utility to automatically rename device names based on
  predetermined rules such as MAC addresses or PCI IDs and PCI/USB slots.
endef

define Package/static-device-names/conffiles
/etc/config/static-device-names
endef

define Build/Compile
endef

define Package/static-device-names/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/static-device-names.init $(1)/etc/init.d/static-device-names
	$(INSTALL_DIR) $(1)/etc/hotplug.d/net
	$(INSTALL_BIN) ./files/static-device-names.hotplug $(1)/etc/hotplug.d/net/00-00-static-device-names
	$(INSTALL_DIR) $(1)/usr/share/doc/static-device-names
	$(INSTALL_DATA) ./README.md $(1)/usr/share/doc/static-device-names/
endef

$(eval $(call BuildPackage,static-device-names))
