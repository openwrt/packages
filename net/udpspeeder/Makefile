#
# Copyright (c) 2017 Yu Wang <wangyucn@gmail.com>
# Copyright (c) 2020 Nishant Sharma <nishant@hopbox.in>
#
# This is free software, licensed under MIT
#

include $(TOPDIR)/rules.mk

PKG_NAME:=UDPspeeder
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/wangyu-/UDPspeeder
PKG_VERSION:=20260730
PKG_SOURCE_VERSION:=b6a1b5941d9ebb6ef4f6866abdf1e03a47b99b2d
PKG_MIRROR_HASH:=b9a0f3beb1b4e70ae21b6558de222ca1d7f541d41bc6c9b5b131a7b0bf53fba0

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md
PKG_MAINTAINER:=Nishant Sharma <nishant@hopbox.in>, Toni Uhlig <matzeton@googlemail.com>

PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

include $(INCLUDE_DIR)/package.mk

define Package/UDPspeeder
  SECTION:=net
  CATEGORY:=Network
  TITLE:=UDP Network Speed-Up Tool
  URL:=https://github.com/wangyu-/UDPspeeder
  DEPENDS:=+libstdcpp
endef

define Package/UDPspeeder/description
  A Tunnel which Improves your Network Quality on a High-latency Lossy Link by using Forward Error Correction,for All Traffics(TCP/UDP/ICMP)
endef

MAKE_FLAGS += cross_cxx gitversion="$(PKG_VERSION)"

define Package/UDPspeeder/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/speederv2_cross $(1)/usr/bin/udpspeeder

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/udpspeeder-config $(1)/etc/config/udpspeeder

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/udpspeeder-init $(1)/etc/init.d/udpspeeder
endef

define Package/UDPspeeder/conffiles
/etc/config/udpspeeder
endef

$(eval $(call BuildPackage,UDPspeeder))
