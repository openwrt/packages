include $(TOPDIR)/rules.mk

PKG_NAME:=prometheus-statsd-exporter
PKG_VERSION:=0.8.1
PKG_RELEASE:=3

PKG_SOURCE:=statsd_exporter-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/prometheus/statsd_exporter/tar.gz/v${PKG_VERSION}?
PKG_HASH:=d69af3ccdc393ec2d3007dd9d039d4f0f0a6dd9df55fb7cd3fd0304607324d51
PKG_BUILD_DIR:=$(BUILD_DIR)/statsd_exporter-$(PKG_VERSION)

PKG_MAINTAINER:=Andre Heider <a.heider@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/prometheus/statsd_exporter

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/prometheus-statsd-exporter
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=StatsD to Prometheus metrics exporter
  URL:=http://prometheus.io
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/prometheus-statsd-exporter/description
statsd_exporter receives StatsD-style metrics and exports them as Prometheus
metrics.
endef

define Package/prometheus-statsd-exporter/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(CP) ./files/* $(1)/
endef

define Package/prometheus-statsd-exporter/conffiles
/etc/prometheus-statsd-exporter.yml
endef

$(eval $(call GoBinPackage,prometheus-statsd-exporter))
$(eval $(call BuildPackage,prometheus-statsd-exporter))
