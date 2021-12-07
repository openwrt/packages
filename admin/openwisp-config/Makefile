# openwisp.org
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
include $(TOPDIR)/rules.mk

PKG_NAME:=openwisp-config
PKG_RELEASE:=1

PKG_MAINTAINER:=Federico Capoano <f.capoano@openwisp.io>
PKG_LICENSE:=GPL3.0-or-later

PKG_SOURCE_URL:=https://github.com/openwisp/openwisp-config.git
PKG_MIRROR_HASH:=b1f5682715cc5b5623b2acf49ebb75d8bac1b58094981b61ede3ca392bdfa269
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2021-12-07
PKG_SOURCE_VERSION:=08df34db29180a0d13c2e357723e8c546523014a
PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/openwisp-config
  TITLE:=Remote configuration management agent
  CATEGORY:=Administration
  SECTION:=admin
  SUBMENU:=openwisp
  DEPENDS:=+curl \
    +lua \
    +libuci-lua \
    +luafilesystem \
    +luci-lib-nixio \
    +ca-certificates
  PKGARCH:=all
  URL:=https://openwisp.org
endef

define Build/Compile
endef

define Package/openwisp-config/conffiles
/etc/config/openwisp
endef

define Package/openwisp-config/install
	$(INSTALL_DIR) \
		$(1)/usr/sbin \
		$(1)/etc/init.d \
		$(1)/etc/config \
		$(1)/etc/openwisp \
		$(1)/usr/lib/lua/openwisp

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-config/files/openwisp.agent \
		$(1)/usr/sbin/openwisp_config

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-config/files/openwisp.init \
		$(1)/etc/init.d/openwisp_config

	$(INSTALL_CONF) $(PKG_BUILD_DIR)/openwisp-config/files/openwisp.config \
		$(1)/etc/config/openwisp

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-config/files/sbin/openwisp-reload-config \
		$(1)/usr/sbin/openwisp-reload-config

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-config/files/lib/openwisp/utils.lua \
		$(1)/usr/lib/lua/openwisp/utils.lua

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-config/files/lib/openwisp/net.lua \
		$(1)/usr/lib/lua/openwisp/net.lua

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-config/files/sbin/openwisp-store-unmanaged.lua \
		$(1)/usr/sbin/openwisp-store-unmanaged

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-config/files/sbin/openwisp-restore-unmanaged.lua \
		$(1)/usr/sbin/openwisp-restore-unmanaged

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-config/files/sbin/openwisp-remove-default-wifi.lua \
		$(1)/usr/sbin/openwisp-remove-default-wifi

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-config/files/sbin/openwisp-uci-autoname.lua \
		$(1)/usr/sbin/openwisp-uci-autoname

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-config/files/sbin/openwisp-update-config.lua \
		$(1)/usr/sbin/openwisp-update-config

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-config/files/sbin/openwisp-get-address.lua \
		$(1)/usr/sbin/openwisp-get-address

	$(CP) $(PKG_BUILD_DIR)/VERSION $(1)/etc/openwisp/
endef

$(eval $(call BuildPackage,openwisp-config))
