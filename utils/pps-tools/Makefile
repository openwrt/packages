#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pps-tools
PKG_VERSION:=2014-08-01
PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ago/pps-tools
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=0deb9c7e135e9380a6d09e9d2e938a146bb698c8
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2

PKG_MAINTAINER:=Zoltan HERPAI <wigyori@uid0.hu>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/pps-tools
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=PPS-tools
endef

define Package/pps-tools/description
  Userland tools for GPS and DCF-77 Clock synchronization. PPS support in Kernel must be enabled.
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/timepps.h $(1)/usr/include/
endef

define Package/pps-tools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ppsctl $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ppstest $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ppswatch $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,pps-tools))
