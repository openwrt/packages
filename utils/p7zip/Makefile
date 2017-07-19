#
# Copyright (C) 2009-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=p7zip
PKG_VERSION:=16.02
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION)_src_all.tar.bz2
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_HASH:=5eb20ac0e2944f6cb9c2d51dd6c4518941c185347d4089ea89087ffdd6e2341f
PKG_MAINTAINER:=Galih Prastowo Aji <galih.prastowo@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/p7zip
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=p7zip archiver
	URL:=http://http://www.7-zip.org
	DEPENDS:=+libstdcpp +libpthread
endef

define Package/p7zip/description
	p7zip is a tool to extract and create 7z files
endef

define Package/p7zip/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/7za $(1)/usr/bin/
endef

$(eval $(call BuildPackage,p7zip))