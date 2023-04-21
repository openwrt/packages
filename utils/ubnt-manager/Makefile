# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=ubnt-manager
PKG_VERSION:=1
PKG_RELEASE:=2

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/ubnt-manager
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Managment app for Ubiquiti devices
  PKGARCH:=all
  EXTRA_DEPENDS:=dropbear
endef

define Package/ubnt-manager/description
Managment app for Ubiquiti devices.
endef

define Package/ubnt-manager/conffiles
/etc/config/ubnt-manager
endef

define Build/Compile
endef

define Package/ubnt-manager/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/ubnt-manager.sh $(1)/usr/bin/ubnt-manager
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/ubnt-manager.config $(1)/etc/config/ubnt-manager
endef

$(eval $(call BuildPackage,ubnt-manager))
