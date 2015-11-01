#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=unrar
PKG_VERSION:=5.3.7
PKG_RELEASE:=1

PKG_SOURCE:=unrarsrc-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.rarlab.com/rar
PKG_MD5SUM:=668f8de87b74d9fa7037d3d487200149
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

PKG_LICENSE:=UnRAR
PKG_LICENSE_FILES:=license.txt

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/unrar
PKG_INSTALL:=1

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/unrar/Default
  TITLE:=UnRAR
  SUBMENU:=Compression
  URL:=http://www.rarlab.com/
  DEPENDS:=$(CXX_DEPENDS) +libpthread
endef

define Package/unrar
$(call Package/unrar/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE+= (application)
endef

define Package/libunrar
$(call Package/unrar/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= (library)
endef

define Package/unrar/description
  UnRAR is an application that can decompress files and archives created using
  the RAR compression scheme
endef

define Package/libunrar/description
  UnRAR library is a shared library that provides file extraction from RAR
  archives
endef

define Build/Compile
	$(call Build/Compile/Default,unrar)
	$(call Build/Compile/Default,lib)
endef

define Package/unrar/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/unrar $(1)/usr/bin/
endef

define Package/libunrar/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libunrar.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,unrar))
$(eval $(call BuildPackage,libunrar))
