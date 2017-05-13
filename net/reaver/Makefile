#
# Copyright (C) 2012-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=reaver
PKG_VERSION:=1.4
PKG_RELEASE:=2
PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/reaver-wps
PKG_MD5SUM:=05441dda7bacfcbe1e831c85d1ea3bc9
PKG_LICENSE:=GPL-2.0

PKG_USE_MIPS16:=0
PKG_AUTOMAKE_PATHS:=src
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_PATH:=src
MAKE_PATH:=src

define Package/reaver
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=wireless
  TITLE:=Efficient brute force attack against Wifi Protected Setup
  URL:=https://code.google.com/p/reaver-wps/
  DEPENDS:=+libpcap +libsqlite3
endef

define Package/reaver/description
  Reaver targets the external registrar functionality mandated by the WiFi
  Protected Setup specification.
  Access points will provide authenticated registrars with their current
  wireless configuration (including the WPA PSK), and also accept a new
  configuration from the registrar.
endef

define Package/reaver/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/{reaver,wash} $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/reaver
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/reaver.db $(1)/etc/reaver/
endef

$(eval $(call BuildPackage,reaver))
