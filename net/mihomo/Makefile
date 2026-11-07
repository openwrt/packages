#
# Copyright (C) 2026 Inceptzws
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=mihomo
PKG_VERSION:=1.18.0
PKG_RELEASE:=1

PKG_SOURCE:=mihomo-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/MetaCubeX/mihomo/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=e9958904180437fc9526b3d43f0b4c23d5bf560cc64bfb32a4bfc6f6c644eb3d
PKG_BUILD_DIR:=$(BUILD_DIR)/mihomo-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_MAINTAINER:=Inceptzws <Inceptzws@users.noreply.github.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_CPE_ID:=cpe:/a:metacubex:mihomo
PKG_LICENSE_FILES:=LICENSE

GO_PKG:=github.com/metacubex/mihomo
GO_PKG_LDFLAGS_X:=github.com/metacubex/mihomo/constant.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/mihomo
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=A rule-based tunnel in Go
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
  URL:=https://github.com/MetaCubeX/mihomo
  PKGARCH:=$(GO_ARCH)
endef

define Package/mihomo/description
  mihomo (formerly Clash.Meta) is a rule-based tunnel supporting multiple
  proxy protocols. It is commonly used on routers as a transparent proxy.

  This package builds the core with the "with_low_memory" build tag, which
  reduces runtime memory usage substantially. On MT7621A / 128 MB class
  devices only about 47 MB of RAM is usable and the default build measures
  roughly 21 MB of peak heap, which leaves the system thrashing; the
  low-memory build measures roughly 12 MB and keeps the device responsive.
endef

define Package/mihomo/conffiles
/etc/config/mihomo
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
endef

define Package/mihomo/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/mihomo $(1)/usr/bin/mihomo
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mihomo.init $(1)/etc/init.d/mihomo
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/mihomo.config $(1)/etc/config/mihomo
	$(INSTALL_DIR) $(1)/etc/mihomo
	$(INSTALL_CONF) ./files/config.yaml $(1)/etc/mihomo/config.yaml
endef

$(eval $(call GoBinPackage,mihomo))
$(eval $(call BuildPackage,mihomo))
