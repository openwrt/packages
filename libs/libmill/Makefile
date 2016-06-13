#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmill
PKG_VERSION:=1.2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=http://libmill.org/
PKG_MD5SUM:=e231fe4323538d0b3255a3b6f54ab7b7
PKG_LICENSE:=MIT/X11
PKG_LICENSE_FILE:=COPYING

PKG_FIXUP:=autoreconf -ivf


include $(INCLUDE_DIR)/package.mk


define Package/libmill
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Libmill is a library that introduces Go-style concurrency to C
  DEPENDS:=+librt
  URL:=http://libmill.org
  MAINTAINER:=Thomas Kee <xsited@yahoo.com>
endef

define Package/nanomsg/description
	Libmill is a library that introduces Go-style concurrency to C.
	It can execute up to 20 million coroutines and 50 million context switches per second.
endef

define Package/libmill/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/.libs/libmill.so* $(1)/usr/lib/
endef


$(eval $(call BuildPackage,libmill))
