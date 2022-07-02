# SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=prometheus-node-exporter
PKG_VERSION:=1.3.1
PKG_RELEASE:=1

PKG_BUILD_DIR=$(BUILD_DIR)/node_exporter-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/prometheus/node_exporter/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=66856b6b8953e094c46d7dd5aabd32801375cf4d13d9fe388e320cbaeaff573a

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Shenghao Yang <me@shenghaoyang.info>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/prometheus/node_exporter
GO_PKG_BUILD_PKG:=$(GO_PKG)
GO_PKG_TAGS:=netgo,osusergo,static_build
GO_PKG_LDFLAGS_X:=\
	github.com/prometheus/common/version.Version=v$(PKG_VERSION) \
	github.com/prometheus/common/version.Revision=a2321e7b940ddcff26873612bccdf7cd4c42b6b6 \
	github.com/prometheus/common/version.Branch=HEAD \
	github.com/prometheus/common/version.BuildUser=openwrt \
	github.com/prometheus/common/version.BuildDate=$(SOURCE_DATE_EPOCH)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/prometheus-node-exporter
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Exporter for machine metrics
  URL:=https://github.com/prometheus/node_exporter
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/prometheus-node-exporter/description
Prometheus exporter for hardware and OS metrics exposed by *NIX kernels,
written in Go with pluggable metric collectors.
endef

define Package/prometheus-node-exporter/install
	$(call GoPackage/Package/Install/Bin,$(1))
	mv $(1)/$(GO_PKG_INSTALL_BIN_PATH)/node_exporter $(1)/usr/bin/prometheus-node-exporter
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/prometheus-node-exporter $(1)/etc/config/prometheus-node-exporter
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/prometheus-node-exporter $(1)/etc/init.d/prometheus-node-exporter
	$(INSTALL_DIR) $(1)/usr/share/doc/prometheus-node-exporter
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/NOTICE $(1)/usr/share/doc/prometheus-node-exporter/NOTICE
endef

define Package/prometheus-node-exporter/conffiles
/etc/config/prometheus-node-exporter
endef

$(eval $(call GoBinPackage,prometheus-node-exporter))
$(eval $(call BuildPackage,prometheus-node-exporter))
