# SPDX-Identifier-License: GPL-3.0-only
#
# openwisp.org

include $(TOPDIR)/rules.mk

PKG_NAME:=openwisp-monitoring
PKG_RELEASE:=2

PKG_MAINTAINER:=Federico Capoano <support@openwisp.io>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_URL:=https://github.com/openwisp/openwrt-openwisp-monitoring.git
PKG_MIRROR_HASH:=b09f2b6ac1a41b6abab3d85917c02b16a94bfec3876c6062108ce600a4a25d98
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=0.1.1
PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/openwisp-monitoring
  TITLE:=OpenWISP Monitoring agent
  CATEGORY:=Administration
  SECTION:=admin
  SUBMENU:=openwisp
  DEPENDS:=+netjson-monitoring +openwisp-config
  URL:=http://openwisp.org
endef

define Package/netjson-monitoring
  TITLE:=NetJson Monitoring
  CATEGORY:=Administration
  SECTION:=admin
  SUBMENU:=openwisp
  DEPENDS:=+libubus-lua +lua-cjson +rpcd +rpcd-mod-iwinfo
  URL:=http://openwisp.org
endef

define Build/Compile
endef

define Package/openwisp-monitoring/conffiles
/etc/config/openwisp-monitoring
endef

define Package/netjson-monitoring/install
	$(INSTALL_DIR) \
		$(1)/usr/sbin \
		$(1)/usr/libexec \
		$(1)/usr/lib/lua/openwisp-monitoring \
		$(1)/etc/openwisp-monitoring

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/sbin/netjson-monitoring.lua \
		$(1)/usr/libexec/netjson-monitoring

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/netjson-monitoring \
		$(1)/usr/sbin/netjson-monitoring

	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/lib/openwisp-monitoring/dhcp.lua \
		$(1)/usr/lib/lua/openwisp-monitoring/dhcp.lua

	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/lib/openwisp-monitoring/interfaces.lua \
		$(1)/usr/lib/lua/openwisp-monitoring/interfaces.lua

	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/lib/openwisp-monitoring/monitoring.lua \
		$(1)/usr/lib/lua/openwisp-monitoring/monitoring.lua

	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/lib/openwisp-monitoring/utils.lua \
		$(1)/usr/lib/lua/openwisp-monitoring/utils.lua

	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/lib/openwisp-monitoring/neighbors.lua \
		$(1)/usr/lib/lua/openwisp-monitoring/neighbors.lua

	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/lib/openwisp-monitoring/resources.lua \
		$(1)/usr/lib/lua/openwisp-monitoring/resources.lua

	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/lib/openwisp-monitoring/wifi.lua \
		$(1)/usr/lib/lua/openwisp-monitoring/wifi.lua

	$(CP) $(PKG_BUILD_DIR)/VERSION $(1)/etc/openwisp-monitoring/

endef

define Package/openwisp-monitoring/install
	$(INSTALL_DIR) \
		$(1)/usr/sbin \
		$(1)/etc/init.d \
		$(1)/etc/config \
		$(1)/etc/openwisp-monitoring

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/monitoring.agent \
		$(1)/usr/sbin/openwisp-monitoring

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/monitoring.init \
		$(1)/etc/init.d/openwisp-monitoring

	$(INSTALL_CONF) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/monitoring.config \
		$(1)/etc/config/openwisp-monitoring

endef

$(eval $(call BuildPackage,openwisp-monitoring))
$(eval $(call BuildPackage,netjson-monitoring))
