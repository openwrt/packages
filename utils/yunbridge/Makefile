#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=yunbridge
PKG_VERSION:=1.6.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://codeload.github.com/arduino/YunBridge/tar.gz/$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=9e5ffc7a0d0cc2c92e972e425adcc49b77cf39da075d31728e7755d316d910d8
PKG_BUILD_DIR:=$(BUILD_DIR)/YunBridge-$(PKG_VERSION)

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
