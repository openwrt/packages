#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=yunbridge
PKG_VERSION:=160

PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/arduino/YunBridge.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=f2042052115e71ad2c91f77e78d21db8275fcdd6
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=367db3667c6d2d8e20a0a214895e1bf2546918b008d084c3e7ca1adba9527dda

PKG_MAINTAINER:=John Crispin <blogic@openwrt.org>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/yunbridge
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Arduino YUN bridge library
  URL:=http://arduino.cc/
  DEPENDS:=+python
endef

define Package/yunbridge/description
  Arduino YUN bridge library
endef

define Build/Compile
	true
endef

define Package/yunbridge/install
	mkdir -p $(1)/usr/lib/python2.7/bridge
	$(CP) $(PKG_BUILD_DIR)/bridge/*.py $(1)/usr/lib/python2.7/bridge/
	$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,yunbridge))
