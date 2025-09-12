include $(TOPDIR)/rules.mk

PKG_NAME:=mihomo
PKG_VERSION:=1.19.10
PKG_RELEASE:=1

PKG_SOURCE=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/metacubex/mihomo/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a0ca7bb23fcfa067e8a58a9618879a507881dbca321a8eb0550948b1d26296c0

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Shin Rag <zhdlcc@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/metacubex/mihomo
GO_PKG_LDFLAGS:=-w -s -buildid=
GO_PKG_LDFLAGS_X:=$(GO_PKG)/constant.Version=$(PKG_VERSION) $(GO_PKG)/constant.BuildTime=$(SOURCE_DATE_EPOCH)
GO_PKG_EXCLUDES:=/logic_test

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/mihomo
	TITLE:=Rule-based tunnel
	SECTION:=net
	CATEGORY:=Network
	URL:=https://github.com/MetaCubeX/mihomo
	USERID:=mihomo:mihomo
	DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/mihomo/description
	Mihomo is a rule-based tunnel that supports multiple protocols, including
	HTTP, HTTPS, SOCKS5, Shadowsocks, VMess and so on.
endef

define Package/mihomo/config
	menu "Select build options"
		depends on PACKAGE_mihomo

		config MIHOMO_WITH_GVISOR
			bool "Build with gVisor support"
			default n
	endmenu
endef

PKG_CONFIG_DEPENDS:=CONFIG_MIHOMO_WITH_GVISOR

GO_PKG_TAGS:=$(if $(CONFIG_MIHOMO_WITH_GVISOR),with_gvisor)

define Package/mihomo/conffiles
/etc/config/mihomo
/etc/mihomo/config.yaml
endef

define Package/mihomo/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/mihomo/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/docs/config.yaml $(1)/etc/mihomo/config.yaml

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/mihomo.conf $(1)/etc/config/mihomo

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/mihomo.init $(1)/etc/init.d/mihomo
endef

$(eval $(call BuildPackage,mihomo))
$(eval $(call GoBinPackage,mihomo))
