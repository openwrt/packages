include $(TOPDIR)/rules.mk

PKG_NAME:=netbird
PKG_VERSION:=0.29.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/netbirdio/netbird/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=9072d16845de49ce395b150564b82f97a33defe007276b6b46d733306b6760ee

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/netbirdio/netbird
GO_PKG_BUILD_PKG:=$(GO_PKG)/client
GO_PKG_LDFLAGS_X:=$(GO_PKG)/version.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/netbird
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=Connect your devices into a single secure private WireGuard®-based mesh network
  URL:=https://netbird.io
  DEPENDS:=$(GO_ARCH_DEPENDS) +kmod-wireguard
endef

define Package/netbird/description
  NetBird is an open-source VPN management platform built on top of WireGuard® making it easy to create
  secure private networks for your organization or home.

  It requires zero configuration effort leaving behind the hassle of opening ports, complex firewall rules, VPN
  gateways, and so forth.
endef

define Package/netbird/conffiles
/etc/netbird/config.json
endef

# Workaround for musl 1.2.4 compability in mattn/go-sqlite3
# https://github.com/mattn/go-sqlite3/issues/1164
ifneq ($(CONFIG_USE_MUSL),)
	TARGET_CFLAGS += -D_LARGEFILE64_SOURCE
endif

define Package/netbird/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/client $(1)/usr/bin/netbird
	$(INSTALL_BIN) ./files/netbird.init $(1)/etc/init.d/netbird
endef

$(eval $(call GoBinPackage,netbird))
$(eval $(call BuildPackage,netbird))
