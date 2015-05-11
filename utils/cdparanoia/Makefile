#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cdparanoia-III
PKG_VERSION:=10.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).src.tgz
PKG_SOURCE_URL:=http://downloads.xiph.org/releases/cdparanoia/
PKG_SOURCE_TARGETDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_MD5SUM:=b304bbe8ab63373924a744eac9ebc652

PKG_BUILD_PARALLEL:=0

include $(INCLUDE_DIR)/package.mk

define Package/cdparanoia
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Cdparanoia
  DEPENDS:=+librt
  URL:=http://www.xiph.org/paranoia/index.html
endef

#define Build/Configure
#	echo "Build/Configure"
#        $(call Build/Configure/Default)
#endef

#define Build/Compile
#endef

define Build/InstallDev
	echo "Build/InstallDev"
endef

define Package/cdparanoia/install
	echo "package/cdparanoia/install"
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/cdparanoia $(1)/usr/bin
#	$(CP) $(PKG_BUILD_DIR)/paranoia/libcdda_paranoia.so.0.$(PKG_VERSION) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/paranoia/libcdda_paranoia.so.* $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/interface/libcdda_interface.so.* $(1)/usr/lib
endef

$(eval $(call BuildPackage,cdparanoia))
