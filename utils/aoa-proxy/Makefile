#
# Copyright (C) 2023 Jó Ágila Bitsch
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
 
PKG_NAME:=aoa-proxy
PKG_VERSION:=0.2
PKG_RELEASE:=1
 
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/jo-bitsch/$(PKG_NAME)/archive/refs/tags/v$(PKG_VERSION).tar.gz?
PKG_HASH:=3a9dc94a3cd1b0cba1ae80396b21a6a63289f20dc426be7836834e5a3fc23a68

PKG_BUILD_DEPENDS:=!USE_GLIBC:argp-standalone

PKG_MAINTAINER:=Jó Ágila Bitsch <jgilab@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
 
include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -DNO_HID=1
 
define Package/aoa-proxy
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Interact with Android devices using AOA
  URL:=https://github.com/jo-bitsch/aoa-proxy
  DEPENDS:=+libusb-1.0
endef
 
define Package/aoa-proxy/description
  This program aims to make working with Android Open Accessory (in 
  particular v1) as easy as possible.
  It has 2 modes, depending on the state of the attached Android device.
  (1) Announce mode: When the Android device is not yet in AOA mode, this
      program announces its identity to the Android device and tries to
      put it into AOA mode.
  (2) Forwarding mode: Forward all input from stdin to the AOA device and
      all output from AOA to stdout.
  For OpenWrt, it includes a hotplug script and a service to automatically
  announce itself and forward AOA traffic to SSH/dropbear.
endef

define Build/Compile
  $(call Build/Compile/Default,aoa-proxy OPENWRT=1)
endef
 
define Package/aoa-proxy/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/aoa-proxy $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/usb
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/etc/hotplug.d/usb/99-aoa-proxy $(1)/etc/hotplug.d/usb/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/etc/init.d/aoa-proxy-forward $(1)/etc/init.d/
endef
 
$(eval $(call BuildPackage,aoa-proxy))