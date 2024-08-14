#
# Copyright (C) 2021 Karl Osterseher <karli_o@gmx.at>
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bluez-tools
PKG_RELEASE:=1

PKG_MAINTAINER:=Karl Osterseher <karli_o@gmx.at>

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/khvzak/bluez-tools.git
PKG_SOURCE_DATE:=2020-10-25
PKG_SOURCE_VERSION:=f65321736475429316f07ee94ec0deac8e46ec4a
PKG_MIRROR_HASH:=f482de511114223d2896bf039473561d02ffcddd6eab0e127d9d8f9e4149fc13

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/bluez-tools
  SECTION:=Utilities
  CATEGORY:=Utilities
  DEPENDS:=+bluez-daemon +glib2
  TITLE:=Bluetooth tools
  URL:=https://github.com/khvzak/bluez-tools
endef

define Package/bluez-tools/description
  Bluetooth tools for bluez daemon. This will install bt-agent only!
endef

define Package/bluez-tools/conffiles
  /etc/config/btagent
endef

define Package/bluez-tools/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/btagent.init $(1)/etc/init.d/btagent
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/btagent.cfg $(1)/etc/config/btagent
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/bt-agent $(1)/usr/bin/
endef

$(eval $(call BuildPackage,bluez-tools))
