#
# Copyright (C) 2009-2010 OpenWrt.org
# Copyright (C) 2009 Jakob Pfeiffer
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=c-ares
PKG_VERSION:=1.11.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://c-ares.haxx.se/download
PKG_MD5SUM:=d5c6d522cfc54bb6f215a0b7912d46be

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

TARGET_CPPFLAGS += $(filter -D%,$(TARGET_CFLAGS))
TARGET_CFLAGS := $(filter-out -D%,$(TARGET_CFLAGS))

define Package/libcares
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for asyncronous DNS Requests (including name resolves)
  URL:=http://c-ares.haxx.se/
  MAINTAINER:=Karl Palsson <karlp@remake.is>
endef

define Package/libcares/description
  c-ares is a C library for asynchronous DNS requests (including name resolves)

C89 compatibility, MIT licensed, builds for and runs on POSIX, Windows,
Netware, Android and many more operating systems.

endef

define Package/libcares/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so.* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)
	$(CP) $(PKG_INSTALL_DIR)/* $(1)/
endef

$(eval $(call BuildPackage,libcares))
