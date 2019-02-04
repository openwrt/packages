include $(TOPDIR)/rules.mk

PKG_NAME:=prometheus
PKG_VERSION:=2.7.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/prometheus/prometheus/tar.gz/v${PKG_VERSION}?
PKG_HASH:=bfbeb434342a03b5849e2ec7a0cbe573067299cf59ccf59db0cacd8db8800bb0

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/prometheus/prometheus/
GO_PKG_BUILD_PKG:=github.com/prometheus/prometheus/cmd/prometheus/

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/prometheus/Default
  TITLE:=Monitoring system & time series database
  USERID:=prometheus=112:prometheus=112
  URL:=http://prometheus.io
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/prometheus
$(call Package/prometheus/Default)
  SECTION:=utils
  CATEGORY:=Utilities
endef

define Package/prometheus/description
Prometheus, a Cloud Native Computing Foundation project, is a systems and
service monitoring system. It collects metrics from configured targets at given
intervals, evaluates rule expressions, displays the results, and can trigger
alerts if some condition is observed to be true.
endef

define Package/prometheus/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(CP) ./files/* $(1)/
endef

define Package/prometheus/conffiles
/etc/prometheus.yml
endef

$(eval $(call GoBinPackage,prometheus))
$(eval $(call BuildPackage,prometheus))
