#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libid3tag
PKG_VERSION:=0.15.1b
PKG_RELEASE:=5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/mad
PKG_MD5SUM:=e5808ad997ba32c498803822078748c3
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_LICENSE:=GPL-2
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libid3tag
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+zlib
  TITLE:=An ID3 tag manipulation library
  URL:=http://mad.sourceforge.net/
endef

define Package/libid3tag/description
	libid3tag is a library for reading and (eventually) writing ID3 tags, both
	ID3v1 and the various versions of ID3v2.
endef

TARGET_CFLAGS += $(FPIC)

# If you get stuck, please install gperf first.
GPERF := $(shell command -v gperf)
ifndef GPERF
	$(error Please install gperf)
endif

CONFIGURE_ARGS+= \
	--enable-shared \
	--enable-static \
	--disable-debugging \
	--disable-profiling

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/id3tag.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/id3tag.pc $(1)/usr/lib/pkgconfig/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libid3tag.{a,so*} $(1)/usr/lib/
endef

define Package/libid3tag/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libid3tag.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libid3tag))
