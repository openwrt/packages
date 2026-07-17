#
# Copyright (c) 2017 Yu Wang <wangyucn@gmail.com>
# Copyright (c) 2020 Nishant Sharma <nishant@hopbox.in>
#
# This is free software, licensed under MIT
#

include $(TOPDIR)/rules.mk

PKG_NAME:=UDPspeeder
PKG_VERSION:=20230206.0
PKG_RELEASE:=5

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/wangyu-/UDPspeeder
PKG_MIRROR_HASH:=8196a07089112a164ea07cc95806f79075bd1b12cc7af5316e2793421bb2cfbf

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Nishant Sharma <nishant@hopbox.in>, Toni Uhlig <matzeton@googlemail.com>

PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

include $(INCLUDE_DIR)/package.mk

define Package/UDPspeeder
  SECTION:=net
  CATEGORY:=Network
  TITLE:=UDP Network Speed-Up Tool
  URL:=https://github.com/wangyu-/UDPspeeder
  DEPENDS:=+libstdcpp +librt +libatomic
endef

define Package/UDPspeeder/description
  A Tunnel which Improves your Network Quality on a High-latency Lossy Link by using Forward Error Correction,for All Traffics(TCP/UDP/ICMP)
endef

MAKE_FLAGS += cross gitversion="$(PKG_VERSION)"

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
