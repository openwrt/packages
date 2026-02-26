# SPDX-Identifier-License: GPL-3.0-only
#
# openwisp.org

include $(TOPDIR)/rules.mk

PKG_NAME:=openwisp-monitoring
PKG_VERSION:=0.3.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Federico Capoano <support@openwisp.io>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:=CONFIG_NETJSON_MONITORING_IWINFO

PKG_SOURCE_URL:=https://github.com/openwisp/openwrt-openwisp-monitoring.git
PKG_MIRROR_HASH:=a7778b0de1b560abf5bf5b8e6e45313fe58309a66438f3c9e043adc8f0248c04
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/openwisp-monitoring
  TITLE:=OpenWISP Monitoring agent
  CATEGORY:=Administration
  SECTION:=admin
  SUBMENU:=openwisp
  DEPENDS:=+netjson-monitoring +openwisp-config
  URL:=https://openwisp.org
endef

define Package/netjson-monitoring
  TITLE:=NetJSON Monitoring
  CATEGORY:=Administration
  SECTION:=admin
  SUBMENU:=openwisp
  DEPENDS:=+libubus-lua +lua-cjson +rpcd
  DEPENDS+=+NETJSON_MONITORING_IWINFO:rpcd-mod-iwinfo
  URL:=https://openwisp.org
endef

define Package/netjson-monitoring/config
  source "$(SOURCE)/Config.in"
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
		$(1)/usr/lib/openwisp-monitoring

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

# Iwinfo is enabled by default unless specified otherwise
ifeq ($(CONFIG_NETJSON_MONITORING_IWINFO), y)
	$(CP) $(PKG_BUILD_DIR)/openwisp-monitoring/files/lib/openwisp-monitoring/iwinfo.lua $(1)/usr/lib/lua/openwisp-monitoring/iwinfo.lua
endif

	$(CP) $(PKG_BUILD_DIR)/VERSION $(1)/usr/lib/openwisp-monitoring/

endef

define Package/openwisp-monitoring/install
	$(INSTALL_DIR) \
		$(1)/usr/sbin \
		$(1)/etc/init.d \
		$(1)/etc/config \
		$(1)/usr/lib/openwisp-monitoring \
		$(1)/etc/hotplug.d/openwisp

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/monitoring.agent \
		$(1)/usr/sbin/openwisp-monitoring

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/monitoring.init \
		$(1)/etc/init.d/openwisp-monitoring

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/openwisp-monitoring.hotplug \
		$(1)/etc/hotplug.d/openwisp/openwisp-monitoring

	$(INSTALL_CONF) \
		$(PKG_BUILD_DIR)/openwisp-monitoring/files/monitoring.config \
		$(1)/etc/config/openwisp-monitoring

endef

$(eval $(call BuildPackage,openwisp-monitoring))
$(eval $(call BuildPackage,netjson-monitoring))
