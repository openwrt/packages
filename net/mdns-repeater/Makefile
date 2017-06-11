#
# Copyright (C) 2017 Majenko Technologies and (C) 2011 Darell Tan
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mdns-repeater
PKG_VERSION:=2016-10-31
PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/majenkotech/mdns-repeater-uci.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=73d029136eaf006615f77e299602aea33b8a4737
PKG_MIRROR_HASH:=21bd49e3b421d3f841788fd3e27089ab7edda6894bb4eab30fa60530976d20e1

PKG_MAINTAINER:=Matt Jenkins <matt@majenko.co.uk>
PKG_LICENSE:=LGPL-2.1

include $(INCLUDE_DIR)/package.mk

define Package/mdns-repeater
  SECTION:=net
  CATEGORY:=Network
  TITLE:=OpenWrt Multicast repeater
  DEPENDS:=+libuci
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include

define Package/mdns-repeater/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d 
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mdns-repeater $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/mdns-repeater $(1)/etc/init.d/mdns-repeater
endef

$(eval $(call BuildPackage,mdns-repeater))
