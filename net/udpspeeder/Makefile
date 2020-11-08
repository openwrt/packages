#
# Copyright (c) 2017 Yu Wang <wangyucn@gmail.com>
# Copyright (c) 2020 Nishant Sharma <nishant@hopbox.in>
#
# This is free software, licensed under MIT
#

include $(TOPDIR)/rules.mk

PKG_NAME:=UDPspeeder
PKG_VERSION:=20200818.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/wangyu-/$(PKG_NAME)/tar.gz/$(PKG_VERSION)?
PKG_HASH:=54bc6dc1283630ed78c033ae26b0f6af24bb92da17784ec64ae56d6e5ca73dd6

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Nishant Sharma <nishant@hopbox.in>

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/UDPspeeder
	SECTION:=net
	CATEGORY:=Network
	TITLE:=UDP Network Speed-Up Tool
	URL:=https://github.com/wangyu-/UDPspeeder
	DEPENDS:= +libstdcpp +librt
endef

define Package/UDPspeeder/description
	 A Tunnel which Improves your Network Quality on a High-latency Lossy Link by using Forward Error Correction,for All Traffics(TCP/UDP/ICMP)
endef

MAKE_FLAGS += cross

define Build/Prepare
	$(PKG_UNPACK)
	sed -i 's/cc_cross=.*/cc_cross=$(TARGET_CXX)/g' $(PKG_BUILD_DIR)/makefile
	sed -i '/\gitversion/d' $(PKG_BUILD_DIR)/makefile
	echo 'const char * const gitversion = "$(PKG_VERSION)";' > $(PKG_BUILD_DIR)/git_version.h
	$(Build/Patch)
endef

define Package/UDPspeeder/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/speederv2_cross $(1)/usr/bin/udpspeeder

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/udpspeeder-config $(1)/etc/config/udpspeeder

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/udpspeeder-init $(1)/etc/init.d/udpspeeder
endef

$(eval $(call BuildPackage,UDPspeeder))
