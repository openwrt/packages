#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libndpi
PKG_VERSION:=2.2
PKG_RELEASE:=1
PKG_MAINTAINER:=Banglang Huang <banglang.huang@foxmail.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ntop/nDPI.git
PKG_SOURCE_VERSION:=56dcf659de5de5385406068704a89c6a39e34041

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=425f48e21295d4b522d0190181bd5943ae0664c20a3aa47f3c62611dd4c7b93f
PKG_LICENSE:=LGPLv3

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

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
		$(PKG_INSTALL_DIR)/usr/include/libndpi-$(PKG_VERSION).0/libndpi \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libndpi.so* \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libndpi.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libndpi/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libndpi.so* \
		$(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/ndpiReader \
		$(1)/usr/bin/
endef

$(eval $(call BuildPackage,libndpi))
