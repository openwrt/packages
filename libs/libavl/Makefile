#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libavl
PKG_VERSION:=0.3.5
PKG_RELEASE:=1
PKG_HASH:=4497b9e22cdd61ae2fa893b9d5fd6213dc306726d7c4be08c29e173622dca8a0

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).orig.tar.gz
PKG_SOURCE_URL:=http://ftp.debian.org/debian/pool/main/liba/libavl
PKG_BUILD_DIR:=$(BUILD_DIR)/avl-$(PKG_VERSION)
PKG_INSTALL:=1

PKG_MAINTAINER:=Espen Jürgensen <espenjurgensen+openwrt@gmail.com>
PKG_LICENSE:=LGPL-2.0+
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/libavl
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=AVLTree (this is not GNU libavl)
  URL:=https://packages.debian.org/wheezy/libavl1
endef

define Package/libavl/description
  AVLTree is a small implementation of AVL trees for the C programming language.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/avl.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libavl.so* $(1)/usr/lib/
endef

define Package/libavl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libavl.so.*  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libavl))
