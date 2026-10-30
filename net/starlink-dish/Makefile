# SPDX-License-Identifier: MIT
include $(TOPDIR)/rules.mk

PKG_NAME:=starlink-dish
PKG_VERSION:=0.1.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/bigmalloy/starlink-panel/releases/download/v$(PKG_VERSION)/
PKG_HASH:=c938d2a99037f5809c8c848b3026d3e63f4018d08be7d63e61197a817fa39359

PKG_MAINTAINER:=Mike Eiberg <eiberg.michael@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host protobuf/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/starlink-dish
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Starlink dish gRPC client
  URL:=https://github.com/bigmalloy/starlink-panel
  DEPENDS:=$(RUST_ARCH_DEPENDS)
endef

define Package/starlink-dish/description
  CLI tool that queries the Starlink dish gRPC API and outputs
  JSON telemetry. Supports 'dish' (full status), 'reboot' and
  'set-heater-on/off/auto' (snow melt mode) commands.
  Used by luci-app-starlink-panel; can also be called from scripts.
endef

CARGO_PKG_VARS += PROTOC=$(STAGING_DIR_HOSTPKG)/bin/protoc

$(eval $(call RustBinPackage,starlink-dish))
$(eval $(call BuildPackage,starlink-dish))
