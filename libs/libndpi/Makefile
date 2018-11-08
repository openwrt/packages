#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libndpi
PKG_VERSION:=2.4
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ntop/nDPI/tar.gz/$(PKG_VERSION)?
PKG_HASH:=5243e16b1c4a2728e9487466b2b496d8ffef18a44ff7ee6dfdc21e72008c6d29
PKG_BUILD_DIR:=$(BUILD_DIR)/nDPI-$(PKG_VERSION)

PKG_MAINTAINER:=Banglang Huang <banglang.huang@foxmail.com>
PKG_LICENSE:=LGPLv3

PKG_FIXUP:=autoreconf
PKG_BUILD_DEPENDS:=libpcap
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libndpi
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for deep-packet inspection
  URL:=https://github.com/ntop/nDPI
  DEPENDS:=+libpcap +libjson-c
endef

define Package/libndpi/description
  nDPI is an open source LGPLv3 library for deep-packet inspection.
  Based on OpenDPI it includes ntop extensions.
endef

define Build/Configure
	( cd $(PKG_BUILD_DIR); ./autogen.sh )
	$(call Build/Configure/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/local/include/ndpi \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/local/lib/libndpi.so \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libndpi.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libndpi/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/local/lib/libndpi.so \
		$(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/ndpiReader \
		$(1)/usr/bin/
endef

$(eval $(call BuildPackage,libndpi))
