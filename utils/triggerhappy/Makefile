#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=triggerhappy
PKG_VERSION:=0.3.4
PKG_REV:=649bf670a012558393d7c41f3660d0a017edd982
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=git://github.com/wertarbyte/triggerhappy
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>
PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/triggerhappy
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=handle input events and run configured programs
  URL:=http://github.com/wertarbyte/triggerhappy
endef

define Package/triggerhappy/description
	triggerhappy - handle input events and run configured programs
	The daemon thd can handle hotplugged input devices and is configured through
	simple configuration files in /etc/triggerhappy/triggers.d/.
endef

MAKE_FLAGS += \
	$(TARGET_CONFIGURE_OPTS) \
	$(1)

define Package/triggerhappy/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/triggerhappy
	$(INSTALL_DIR) $(1)/etc/triggerhappy/triggers.d/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/input/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/thd $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/th-cmd $(1)/usr/sbin
	$(INSTALL_BIN) ./files/triggerhappy.init $(1)/etc/init.d/triggerhappy
	$(INSTALL_BIN) ./files/triggerhappy.hotplug $(1)/etc/hotplug.d/input/10-triggerhappy
	$(INSTALL_BIN) ./files/triggerhappy-example.conf $(1)/etc/triggerhappy/triggers.d/example.conf
endef

$(eval $(call BuildPackage,triggerhappy))
