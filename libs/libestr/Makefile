#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libestr
PKG_VERSION:=0.1.10
PKG_RELEASE:=2

PKG_SOURCE_URL:=http://libestr.adiscon.com/files/download/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=f4c9165a23587e77f7efe65d676d5e8e

PKG_MAINTAINER:=Dov Murik <dmurik@us.ibm.com>
PKG_LICENSE:=LGPL-2.1+
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libestr
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=String handling library
  URL:=http://libestr.adiscon.com/
endef

define Package/libestr/description
  libestr - some essentials for string handling (and a bit more)
endef

TARGET_CFLAGS += $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Package/libestr/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libestr.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libestr))
