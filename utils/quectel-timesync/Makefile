# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=quectel-timesync
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/freifunk-darmstadt/quectel-timesync.git
PKG_SOURCE_DATE:=2023-10-08
PKG_SOURCE_VERSION:=4333888cb8025b92511597a95859943fae0a0bc8
PKG_MIRROR_HASH:=49b2e24cd23b430a8d2815b10ce1bc2df1a6a6128cb0da1693807ebc130a51e7

PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/quectel-timesync
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Tool for configuring system clock using Quectel cellular modems
  DEPENDS:=+kmod-usb-serial-option
endef

define Package/quectel-timesync/description
This tool allows for acquiring the current time from
the cellular network for configuring the local clock.
Compared to NTP, this has the advantage of nut using up
mobile traffic.

It takes advantage of the AT+QLTS command found on Quectel
modems. This functionality depends on support of the mobile
network.
endef

define Package/quectel-timesync/conffiles
/etc/config/quectel-timesync
endef

define Package/quectel-timesync/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config

	$(CP) $(PKG_BUILD_DIR)/openwrt/quectel-timesync/files/quectel-timesync.config $(1)/etc/config/quectel-timesync

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/quectel-timesync/files/quectel-timesync.init $(1)/etc/init.d/quectel-timesync	
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/quectel-timesync $(1)/usr/sbin/quectel-timesync
endef

$(eval $(call BuildPackage,quectel-timesync))
