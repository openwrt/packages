#
# Copyright (C) 2006-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Author: p4u <pau@dabax.net>

include $(TOPDIR)/rules.mk

PKG_NAME:=dhcpdiscover
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/dhcpdiscover

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/dhcpdiscover
 SECTION:=net
 CATEGORY:=Network
 TITLE:=dhcpdiscover
endef

define Package/dhcpdiscover/description
 Brings some information about the existing DHCP servers of the network
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/dhcpdiscover/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dhcpdiscover $(1)/bin/
endef

$(eval $(call BuildPackage,dhcpdiscover))
