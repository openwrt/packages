#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=noip
PKG_REV:=1
PKG_VERSION:=2.1.9-1
PKG_RELEASE:=1

PKG_SOURCE:=noip-duc-linux.tar.gz
PKG_SOURCE_URL=http://www.noip.com/client/linux/
PKG_MD5SUM:=3b0f5f2ff8637c73ab337be403252a60
PKG_MAINTAINER:="Lawrence D'Anna <larry@elder-gods.org>"

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/noip
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=
  TITLE:=noip.com client
  URL:=http://noip.com
endef

define Package/noip/description
	This is the ip address update client for noip.com
endef

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		PREFIX="" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		BINDIR="$(PKG_INSTALL_DIR)/usr/bin"  \
		CFLAGS="$(TARGET_CFLAGS)" \
		CC="$(TARGET_CC) $(TARGET_CFLAGS)" \
		LD="$(TARGET_CC) $(TARGET_LDFLAGS)" \
		install
endef

define Package/noip/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,noip))
