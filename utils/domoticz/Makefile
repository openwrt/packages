#
# Copyright (C) 2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_REV:=5070
#2107+git rev-list HEAD --count
PKG_NAME:=domoticz
PKG_VERSION:=3.${PKG_REV}
PKG_RELEASE:=2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_USE_MIPS16:=0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/domoticz/domoticz.git
PKG_SOURCE_VERSION:=86f58c92c6e3cd3a6e4a6baea6a3abca3d6593ab
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/domoticz
  SECTION:=Home Automation
  CATEGORY:=Utilities
  TITLE:=Domoticz Home Automation 
  DEPENDS:=+libubacktrace +zlib +libusb-1.0 +libusb-compat +libcurl +libsqlite3 +libopenssl +boost-system +boost-thread +boost-date_time +DOMOTICZ_OZW_SUPPORT:openzwave +DOMOTICZ_WIREPI_SUPPORT:wiringpi +DOMOTICZ_RPITOOLS_SUPPORT:userland
  URL:=https://domoticz.com/
  MAINTAINER:=irimi <irimi@gmx.de>
endef

define Package/domoticz/description
  Domoticz is a Home Automation System that lets you monitor and configure various devices like: 
  Lights, Switches, various sensors/meters like Temperature, Rain, Wind, UV, Electra, Gas, Water and much more. 
  Notifications/Alerts can be sent to any mobile device.
endef


define Package/domoticz/config
  menu "Configuration"
  depends on PACKAGE_domoticz
  source "$(SOURCE)/Config.in"
  endmenu
endef
        
CMAKE_OPTIONS += \
	-DCMAKE_BUILD_TYPE=Release . \
	-DCPACK_STRIP_FILES=1
#	-DDEBUG=1

define Package/domoticz/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/opt/domoticz
	$(CP) $(PKG_INSTALL_DIR)/usr/domoticz $(1)/opt/domoticz/
	$(CP) $(PKG_INSTALL_DIR)/usr/www $(1)/opt/domoticz/
	$(CP) $(PKG_INSTALL_DIR)/usr/Config $(1)/opt/domoticz/
	$(CP) $(PKG_INSTALL_DIR)/usr/scripts $(1)/opt/domoticz/
	$(INSTALL_BIN) ./files/domoticz.init $(1)/etc/init.d/domoticz
endef

######################################
#
# Important: if backtrace functionality is enabled in domoticz uClibc openwrt's settings for uCkibc must be changed:
# LIBC_HAS_BACKTRACE=y
# resp see file [openwrt_root]/toolchain/uClibc/config-0.9.33.2/common
# rebuild uClibc with make ./toolchain/uClibc/{clean, compile} V=s
#
#######################################
define Package/libubacktrace
$(call Package/libc/Default)
	TITLE:=Backtrace extension library
	DEPENDS:=+libpthread
endef

define Package/libubacktrace/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(TOOLCHAIN_DIR)/lib/libubacktrace.so.* $(1)/usr/lib/
	$(CP) $(TOOLCHAIN_DIR)/lib/libubacktrace-* $(1)/usr/lib/
endef
                    
                        
$(eval $(call BuildPackage,domoticz))
$(eval $(call BuildPackage,libubacktrace))
