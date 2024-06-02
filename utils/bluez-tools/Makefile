#
# Copyright (C) 2021 Karl Osterseher <karli_o@gmx.at>
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bluez-tools
PKG_VERSION:=20201025.f653217
PKG_RELEASE:=2

PKG_MAINTAINER:=Karl Osterseher <karli_o@gmx.at>

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/khvzak/bluez-tools.git
PKG_SOURCE_DATE:=2020-10-25
PKG_SOURCE_VERSION:=f65321736475429316f07ee94ec0deac8e46ec4a
PKG_MIRROR_HASH:=153728e0de2bc95b83c9c9ace02a40ccd102eafd5a46c1891ac26212a362d551

PKG_BUILD_DIR:=$(BUILD_DIR)/bluez-tools-$(PKG_VERSION)

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
