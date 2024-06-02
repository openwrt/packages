# SPDX-Identifier-License: GPL-3.0-only
#
# openwisp.org

include $(TOPDIR)/rules.mk

PKG_NAME:=openwisp-config
PKG_RELEASE:=2

PKG_MAINTAINER:=Federico Capoano <f.capoano@openwisp.io>
PKG_LICENSE:=GPL-3.0-or-later

PKG_SOURCE_URL:=https://github.com/openwisp/openwisp-config.git
PKG_MIRROR_HASH:=d1760c42e6388a2431e4c4514ec6d8a519757035b630b2bf0a8574b65effc4c3
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=1.0.1

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
