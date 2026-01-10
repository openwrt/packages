include $(TOPDIR)/rules.mk

PKG_NAME:=sing-box
PKG_VERSION:=1.12.15
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/SagerNet/sing-box/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=3068e558f0a075dc768b2b00ec8b33b5920c92fbbf65b7d336c098a0fa515b21

PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Van Waholtz <brvphoenix@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/sagernet/sing-box
GO_PKG_BUILD_PKG:=$(GO_PKG)/cmd/sing-box

GO_PKG_LDFLAGS_X:=$(GO_PKG)/constant.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/sing-box-default
  TITLE:=The universal proxy platform
  SECTION:=net
  CATEGORY:=Network
  URL:=https://sing-box.sagernet.org
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle +kmod-inet-diag +kmod-tun
  USERID:=sing-box=5566:sing-box=5566
endef

define Package/sing-box
  $(Package/sing-box-default)
  TITLE+= (full)
  VARIANT:=full
  DEFAULT_VARIANT:=1
endef

define Package/sing-box/description
  Sing-box is a universal proxy platform which supports hysteria, SOCKS, Shadowsocks,
  ShadowTLS, Tor, trojan, VLess, VMess, WireGuard and so on.
endef

define Package/sing-box-tiny
  $(Package/sing-box-default)
  TITLE+= (tiny)
  PROVIDES:=sing-box
  VARIANT:=tiny
  CONFLICTS:=sing-box
endef

Package/sing-box-tiny/description:=$(Package/sing-box/description)

define Package/sing-box/config
	menu "Select build options"
		depends on PACKAGE_sing-box

		config SINGBOX_WITH_ACME
			bool "Build with ACME TLS certificate issuer support"

		config SINGBOX_WITH_CLASH_API
			bool "Build with Clash API support"
			default y

		config SINGBOX_WITH_DHCP
			bool "Build with DHCP support, see DHCP DNS transport."

		config SINGBOX_WITH_EMBEDDED_TOR
			bool "Build with embedded Tor support"

		config SINGBOX_WITH_GRPC
			bool "Build with standard gRPC support"

		config SINGBOX_WITH_GVISOR
			bool "Build with gVisor support"
			default y

		config SINGBOX_WITH_QUIC
			bool "Build with QUIC support"
			default y

		config SINGBOX_WITH_TAILSCALE
			bool "Build with Tailscale support"
			default y

		config SINGBOX_WITH_UTLS
			bool "Build with uTLS support for TLS outbound"
			default y

		config SINGBOX_WITH_V2RAY_API
			bool "Build with V2Ray API support"

		config SINGBOX_WITH_WIREGUARD
			bool "Build with WireGuard support"
			default y
	endmenu
endef

PKG_CONFIG_DEPENDS:= \
	CONFIG_SINGBOX_WITH_ACME \
	CONFIG_SINGBOX_WITH_CLASH_API \
	CONFIG_SINGBOX_WITH_DHCP \
	CONFIG_SINGBOX_WITH_EMBEDDED_TOR \
	CONFIG_SINGBOX_WITH_GRPC \
	CONFIG_SINGBOX_WITH_GVISOR \
	CONFIG_SINGBOX_WITH_QUIC \
	CONFIG_SINGBOX_WITH_TAILSCALE \
	CONFIG_SINGBOX_WITH_UTLS \
	CONFIG_SINGBOX_WITH_V2RAY_API \
	CONFIG_SINGBOX_WITH_WIREGUARD

ifeq ($(BUILD_VARIANT),tiny)
ifeq ($(CONFIG_SMALL_FLASH),)
GO_PKG_TAGS:=with_gvisor
endif
GO_PKG_TAGS:=$(GO_PKG_TAGS),with_quic,with_utls,with_clash_api
else
GO_PKG_TAGS:=$(subst $(space),$(comma),$(strip \
	$(if $(CONFIG_SINGBOX_WITH_ACME),with_acme) \
	$(if $(CONFIG_SINGBOX_WITH_CLASH_API),with_clash_api) \
	$(if $(CONFIG_SINGBOX_WITH_DHCP),with_dhcp) \
	$(if $(CONFIG_SINGBOX_WITH_EMBEDDED_TOR),with_embedded_tor) \
	$(if $(CONFIG_SINGBOX_WITH_GRPC),with_grpc) \
	$(if $(CONFIG_SINGBOX_WITH_GVISOR),with_gvisor) \
	$(if $(CONFIG_SINGBOX_WITH_QUIC),with_quic) \
	$(if $(CONFIG_SINGBOX_WITH_TAILSCALE),with_tailscale) \
	$(if $(CONFIG_SINGBOX_WITH_UTLS),with_utls) \
	$(if $(CONFIG_SINGBOX_WITH_V2RAY_API),with_v2ray_api) \
	$(if $(CONFIG_SINGBOX_WITH_WIREGUARD),with_wireguard) \
))
endif

define Package/sing-box/conffiles
/etc/config/sing-box
/etc/sing-box/
endef

Package/sing-box-tiny/conffiles=$(Package/sing-box/conffiles)

define Package/sing-box/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/sing-box $(1)/usr/bin/sing-box

	$(INSTALL_DIR) $(1)/etc/sing-box
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/release/config/config.json $(1)/etc/sing-box

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/sing-box.conf $(1)/etc/config/sing-box
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/sing-box.init $(1)/etc/init.d/sing-box
endef

Package/sing-box-tiny/install=$(Package/sing-box/install)

$(eval $(call BuildPackage,sing-box))
$(eval $(call BuildPackage,sing-box-tiny))
