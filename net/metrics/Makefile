#
# Copyright (C) 2017 Dan Luedtke <mail@danrl.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=metrics
PKG_VERSION:=0.1.20170217
PKG_RELEASE:=1
PKG_LICENSE:=Apache 2.0 License

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)

include $(INCLUDE_DIR)/package.mk

define Package/metrics
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+lua
  TITLE:=Prometheus-compatible Metrics Exporter
  PKGARCH:=all
  MAINTAINER:=Dan Luedtke <mail@danrl.com>
endef

define Package/metrics/description
  A Prometheus-compatible metrics exporter for monitoring and statistics.
endef

define Package/metrics/conffiles
/etc/config/metrics
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/metrics/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/metrics  $(1)/etc/config/metrics
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/metrics   $(1)/etc/init.d/metrics
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/usr/sbin/metrics.lua $(1)/usr/sbin/metrics.lua
endef


$(eval $(call BuildPackage,metrics))
