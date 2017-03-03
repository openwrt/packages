#
# Copyright (C) 2012-2017 www.kunteng.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=masscan
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/robertdavidgraham/masscan.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_HASH:=ef6b8f1789e83f2e4585d16e121d901315efd28a4bfd4fd80fa04a293b3a958e

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Dengfeng Liu <liudengfeng@kunteng.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/masscan
  SECTION:=net
  CATEGORY:=Network
  TITLE:=masscan is the fastest internet port scanner
  DEPENDS:=+libpcap +libpthread +librt
  URL:=https://github.com/liudf0716/masscan
endef

define Package/masscan/description
  Masscan is the fastest Internet port scanner. 
  It can scan the entire Internet in under 6 minutes, 
  transmitting 10 million packets per second.
endef

define Package/masscan/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/masscan $(1)/usr/bin/
endef

$(eval $(call BuildPackage,masscan))
