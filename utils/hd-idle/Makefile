#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hd-idle
PKG_VERSION:=1.04
PKG_RELEASE:=1

PKG_MAINTAINER:=Lim Guo Wei <limguowei@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_MD5SUM:=41e52e669fc59fa82ee0c2bcce1336d3

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/hd-idle
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Another idle-daemon for attached hard drives
  SUBMENU:=disc
  URL:=http://hd-idle.sourceforge.net/
endef

define Package/hd-idle/description
       hd-idle is a utility program for spinning-down external disks after a period of idle time.
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -o $(PKG_BUILD_DIR)/$(PKG_NAME) $(PKG_BUILD_DIR)/$(PKG_NAME).c
endef

define Package/hd-idle/conffiles
/etc/config/hd-idle
endef

define Package/hd-idle/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/$(PKG_NAME).config $(1)/etc/config/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
endef

$(eval $(call BuildPackage,hd-idle))
