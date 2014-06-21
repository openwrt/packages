#
# Copyright (C) 2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mac-to-devinfo
PKG_VERSION:=1.0.0
PKG_RELEASE:=2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/mac-to-devinfo
  SECTION:=net
  CATEGORY:=Network
  TITLE:=MAC Address to Device Information
  MAINTAINER:=Daniel Dickinson <openwrt@cshore.neomailbox.net>
endef

define Package/mac-to-devinfo/description
  Scripts to take a mac address (or ip if the ip is in the arp cache)
  and translate it into device information (mostly OUI owner, from the
  IEEE data files, but more information may be available for specific
  devices/vendors).
endef

define Package/smap-to-devinfo
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Telephony
  DEPENDS:=+mac-to-devinfo +smap +httping
  TITLE:=SIP Device Information from Scan
endef

define Package/smap-to-devinfo/description
  A script to use smap to discover all SIP devices on the networks
  (provided ICMP and SIP are allowed to the network from the host) and
  translate (through the ip then mac) into the device information.
endef

define Package/netdiscover-to-devinfo
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+mac-to-devinfo +netdiscover
  TITLE:=Device Information from Scan for MAC addresses
endef

define Package/netdiscover-to-devinfo/description
  A script to use netdiscover to discover all devices on the specified
  arp-able networks and translate into the device information.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/mac-to-devinfo/conffiles
/etc/config/mactodevinfo
endef

define Package/mac-to-devinfo/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/mac-to-devinfo $(1)/usr/bin
	$(INSTALL_BIN) ./files/ip-to-devinfo $(1)/usr/bin
	$(INSTALL_BIN) ./files/prep-devinfo $(1)/usr/bin
	$(INSTALL_BIN) ./files/clean-devinfo $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/mac-to-devinfo
	$(INSTALL_BIN) ./files/devinfo-functions.sh $(1)/usr/lib/mac-to-devinfo
	$(INSTALL_DIR) $(1)/usr/share/mac-to-devinfo
	$(CP) ./files/macdevdb $(1)/usr/share/mac-to-devinfo
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/mactodevinfo $(1)/etc/config
endef

define Package/smap-to-devinfo/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/smap-to-devinfo $(1)/usr/bin
	$(INSTALL_BIN) ./files/netsmap-to-devinfo $(1)/usr/bin
endef

define Package/netdiscover-to-devinfo/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/netdiscover-to-devinfo $(1)/usr/bin
endef

$(eval $(call BuildPackage,mac-to-devinfo))
$(eval $(call BuildPackage,smap-to-devinfo))
$(eval $(call BuildPackage,netdiscover-to-devinfo))
