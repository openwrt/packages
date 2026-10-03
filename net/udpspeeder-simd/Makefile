#
# Copyright (c) 2026 David Connolly <david@connol.ly>
#
# This is free software, licensed under MIT
#

include $(TOPDIR)/rules.mk

PKG_NAME:=udpspeeder-simd
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/connollydavid/UDPspeeder-simd.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=9ef24879157c493f610ab945c9bbec6c4c95ace929618faf21ccee8a0852e6e4

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md
PKG_MAINTAINER:=David Connolly <david@connol.ly>

PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

include $(INCLUDE_DIR)/package.mk

define Package/udpspeeder-simd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=SIMD-accelerated UDP FEC tunnel
  URL:=https://github.com/connollydavid/UDPspeeder-simd
  DEPENDS:=+libstdcpp +librt +libatomic
endef

define Package/udpspeeder-simd/description
  A Forward Error Correction UDP tunnel that improves a high-latency, lossy link
  with Reed-Solomon redundancy. A SIMD-accelerated fork of UDPspeeder; on targets
  with no SIMD path (for example MIPS) it uses a portable word-width path. Installs
  alongside the udpspeeder package with distinct paths, so the two do not conflict.
endef

MAKE_FLAGS += cross gitversion="$(PKG_VERSION)"

define Package/udpspeeder-simd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/speederv2_cross $(1)/usr/bin/udpspeeder-simd

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/udpspeeder-simd.config $(1)/etc/config/udpspeeder-simd

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/udpspeeder-simd.init $(1)/etc/init.d/udpspeeder-simd
endef

define Package/udpspeeder-simd/conffiles
/etc/config/udpspeeder-simd
endef

$(eval $(call BuildPackage,udpspeeder-simd))
