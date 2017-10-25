#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ntpclient
PKG_VERSION:=2010_365
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://doolittle.icarus.com/ntpclient/
PKG_HASH:=9ad9b028385082fb804167f464e2db0a0b3d33780acd399327e64898b8fcfddd

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_LICENSE:=GPL-2.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-2010

include $(INCLUDE_DIR)/package.mk

define Package/ntpclient
  SUBMENU:=Time Synchronization
  SECTION:=net
  CATEGORY:=Network
  TITLE:=NTP (Network Time Protocol) client
  URL:=http://doolittle.icarus.com/ntpclient/
  DEPENDS:=+librt
endef

define Package/ntpclient/description
	NTP client for setting system time from NTP servers.
endef

define Package/ntpclient/conffiles
/etc/config/ntpclient
endef

MAKE_FLAGS += \
	all adjtimex

define Package/ntpclient/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/ntpclient.hotplug $(1)/etc/hotplug.d/iface/20-ntpclient
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/ntpclient.config $(1)/etc/config/ntpclient
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ntpclient $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/adjtimex $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rate.awk $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,ntpclient))
