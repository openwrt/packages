#
# Copyright (C) 2023 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clevis
PKG_VERSION:=19
PKG_RELEASE:=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/latchset/clevis/archive/refs/tags/
PKG_HASH:=709a23fa31f7d3d918b7e7d3308a08e211824ea8fa43681dbc6fc35cac334001

PKG_MAINTAINER:=Patryk Kowalczyk <patryk@kowalczyk.ws>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING COPYING.openssl

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=!USE_GLIBC:argp-standalone glib2/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/clevis
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Encryption
  TITLE:=Clevis Automated Encryption Framework
  DEPENDS:=+libblkid +libuuid +libpopt +libopenssl +libdevmapper +libjson-c \
           +bash +cryptsetup +curl +jansson +jose +jq +lvm2 +nmap +tang
  URL:=https://github.com/latchset/clevis/
endef

define Package/clevis/description
  Clevis is Automated Encryption Framework used to automat unlock encrypted disks.
endef

define Package/clevis/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/clevis $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/clevis-decrypt $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/luks/clevis-luks-bind $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/luks/clevis-luks-edit $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/luks/clevis-luks-list $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/luks/clevis-luks-pass $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/luks/clevis-luks-regen $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/luks/clevis-luks-report $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/luks/clevis-luks-unlock $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/pins/sss/clevis-decrypt-null $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/pins/sss/clevis-encrypt-null $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/pins/tang/clevis-decrypt-tang $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/pins/tang/clevis-encrypt-tang $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt-build/src/luks/clevis-luks-unbind $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt-build/src/luks/clevis-luks-common-functions $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt-build/src/pins/sss/clevis-decrypt-sss $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt-build/src/pins/sss/clevis-encrypt-sss $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/clevis.init $(1)/etc/init.d/clevis
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/clevis.config $(1)/etc/config/clevis
endef

$(eval $(call BuildPackage,clevis))
