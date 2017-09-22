# 
# Copyright (c) 2015 OpenWrt.org
#
# This is free software, licensed under the BSD 2-Clause License.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=port-mirroring
PKG_VERSION:=1.4.3
PKG_RELEASE:=1
PKG_MAINTAINER:=Mike Maraya <mike.maraya@gmail.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=git://github.com/splatch/port-mirroring.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=7fb9cac2e0d63aa28fadc3f1752a7c64b1740051
PKG_FIXUP:=autoreconf
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/port-mirroring
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+libpcap +libpthread
	TITLE:=Copy network packets with optional support for TaZmen Sniffer Protocol (TZSP) 
	URL:=https://github.com/splatch/port-mirroring
	MENU:=1
endef

define Package/port-mirroring/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/port-mirroring $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/port-mirroring.conf $(1)/etc/config/port-mirroring
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/port-mirroringd $(1)/etc/init.d/port_mirroring
endef

$(eval $(call BuildPackage,port-mirroring))

