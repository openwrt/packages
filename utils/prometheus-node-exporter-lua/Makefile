#
# Copyright (C) 2013-2017 OpenWrt.org
#
include $(TOPDIR)/rules.mk

PKG_NAME:=prometheus-node-exporter-lua
PKG_VERSION:=2017.05.07
PKG_RELEASE:=1

PKG_MAINTAINER:=Christian Simon <simon@swine.de>
PKG_LICENSE:=Apache-2.0

include $(INCLUDE_DIR)/package.mk

define Package/prometheus-node-exporter-lua
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Provides system statistics as Prometheus scraping endpoint
  DEPENDS:=+luasocket
  URL:=https://github.com/rbo/openwrt_exporter
  PKGARCH:=all
endef

define Package/prometheus-node-exporter-lua/conffiles
/etc/config/prometheus-node-exporter-lua
endef

define Package/prometheus-node-exporter-lua/description
  Provides node metrics as Prometheus scraping endpoint.

  This service is a lightweight rewrite in LUA of the offical Prometheus node_exporter.
endef

Build/Compile=

define Package/prometheus-node-exporter-lua/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/prometheus-node-exporter-lua $(1)/etc/config/prometheus-node-exporter-lua
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/prometheus-node-exporter-lua $(1)/etc/init.d/prometheus-node-exporter-lua
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/prometheus-node-exporter-lua $(1)/usr/bin/prometheus-node-exporter-lua
endef

$(eval $(call BuildPackage,prometheus-node-exporter-lua))
