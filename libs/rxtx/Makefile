#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rxtx
PKG_VERSION:=2.2pre2
PKG_RELEASE:=1
PKG_LICENSE:=LGPL-2.1
PKG_MAINTAINER:=Dana H. Myers <k6jq@comcast.net>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).zip
PKG_SOURCE_URL:=http://rxtx.qbang.org/pub/rxtx/
PKG_MD5SUM:=

PKG_FIXUP:=patch-libtool
PKG_INSTALL:=1
PKG_CHECK_FORMAT_SECURITY:=0

include $(INCLUDE_DIR)/package.mk

define Package/rxtx
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=RX/TX
  URL:=http://rxtx.qbang.org/wiki/index.php/Main_Page
  DEPENDS:=+libpthread
endef

define Package/rxtx/Description
	RX/TX Support for serial communications
endef

CONFIGURE_ARGS += \
	--disable-PRINTER

define Package/rxtx/install
	$(INSTALL_DIR) \
		$(1)/usr/lib/classpath
	$(CP) $(PKG_BUILD_DIR)/$(GNU_TARGET_NAME)-gnu/.libs/*.so \
		$(1)/usr/lib/classpath/
	$(CP) $(PKG_BUILD_DIR)/RXTXcomm.jar \
		$(1)/usr/lib/classpath/
endef

define Build/Install
#
endef

$(eval $(call BuildPackage,rxtx))
