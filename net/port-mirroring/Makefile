#
# Copyright (c) 2015 OpenWrt.org
#
# This is free software, licensed under the BSD 2-Clause License.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=port-mirroring
PKG_VERSION:=1.4.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/mmaraya/port-mirroring/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=90603163fb086cc586a711e066360ccfa5b4735f67586e8f9254e93f3bebb97e

PKG_MAINTAINER:=Mike Maraya <mike.maraya@gmail.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/port-mirroring
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+libpcap +libpthread
	TITLE:=Copy network packets with optional support for TaZmen Sniffer Protocol (TZSP)
	URL:=https://github.com/mmaraya/port-mirroring
	MENU:=1
endef

define Package/port-mirroring/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/port-mirroring $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/openwrt/port-mirroring.conf $(1)/etc/config/port-mirroring
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/port-mirroringd $(1)/etc/init.d/port_mirroring
endef

$(eval $(call BuildPackage,port-mirroring))

