#
# Copyright (C) 2007-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=daemonlogger
PKG_VERSION:=1.2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/daemonlogger
PKG_MD5SUM:=acb64aa6cd5777e297569f100b5c39ee

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=Mirko Vogt <mirko@openwrt.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/daemonlogger
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpcap +libdnet
  TITLE:=Software Network Tap
  URL:=http://www.snort.org/snort-downloads/additional-downloads
endef

CONFIGURE_VARS += \
	BUILD_CC="$(TARGET_CC)" \
	HOSTCC="$(HOSTCC)"

MAKE_FLAGS := CCOPT="$(TARGET_CFLAGS)" INCLS="-I. $(TARGET_CPPFLAGS)"

define Package/daemonlogger/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/daemonlogger $(1)/usr/bin/
endef

$(eval $(call BuildPackage,daemonlogger))
