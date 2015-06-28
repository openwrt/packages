#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=unrar
PKG_VERSION:=5.2.7
PKG_RELEASE:=1

PKG_SOURCE:=unrarsrc-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.rarlab.com/rar
PKG_MD5SUM:=0c145e1ac47d428553123462c0740279
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

PKG_LICENSE:=UnRAR
PKG_LICENSE_FILES:=license.txt

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/unrar
PKG_INSTALL:=1

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/unrar
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Compression
  TITLE:=UnRAR application
  URL:=http://www.rarlab.com/
  DEPENDS:=$(CXX_DEPENDS) +libpthread
endef

define Package/unrar/description
   UnRAR is an application that can decompress files and archives created using
   the RAR compression scheme
endef

define Build/Configure
endef

define Package/unrar/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/unrar $(1)/usr/bin/
endef

$(eval $(call BuildPackage,unrar))
