include $(TOPDIR)/rules.mk

PKG_NAME:=udp-proxy-2020
PKG_VERSION:=0.1.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/synfinatic/udp-proxy-2020/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=d0beb56b478e280a719fe59ee5bdc0f88a8b92c240cc0510661e599bd0250c3b

PKG_MAINTAINER:=Bruno HiFi <router.openwrt24@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/synfinatic/udp-proxy-2020
GO_PKG_BUILD_PKG:=github.com/synfinatic/udp-proxy-2020/cmd/udp-proxy-2020
GO_PKG_LDFLAGS_X:=main.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/udp-proxy-2020
  SECTION:=net
  CATEGORY:=Network
  TITLE:=UDP broadcast proxy for routed networks
  URL:=https://github.com/synfinatic/udp-proxy-2020
  DEPENDS:=$(GO_ARCH_DEPENDS) +libpcap
endef

define Package/udp-proxy-2020/description
  udp-proxy-2020 forwards UDP broadcast traffic between configured
  network interfaces. It can be used to relay discovery traffic across
  routed networks or VPNs, including Roon discovery traffic between
  a LAN and WireGuard interface.
endef

define Package/udp-proxy-2020/conffiles
/etc/config/udp-proxy-2020
endef

define Package/udp-proxy-2020/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/udp-proxy-2020.init \
		$(1)/etc/init.d/udp-proxy-2020

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/udp-proxy-2020.config \
		$(1)/etc/config/udp-proxy-2020
endef

$(eval $(call GoBinPackage,udp-proxy-2020))
$(eval $(call BuildPackage,udp-proxy-2020))
