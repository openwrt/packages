#
# Copyright (C) 2007-2016 OpenWrt.org
# Copyright (C) 2017 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=poco
PKG_VERSION:=1.7.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://pocoproject.org/releases/$(PKG_NAME)-$(PKG_VERSION)
PKG_MD5SUM:=17783e30f5ef9c852544ac0e9d1fd316c4804317026059a9d6aad798b61c77f8

PKG_LICENSE:=BSL-1.0
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/poco
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Poco C++ libraries
  URL:=http://www.pocoproject.org/
  DEPENDS:=+libstdcpp +libpthread +librt
  MAINTAINER:=Jean-Michel Julien <jean-michel.julien@trilliantinc.com>
endef

define Package/poco/description
  POrtable COmponents, a modern and powerful open source C++ class libraries
  and frameworks for building network and internet-based applications that
  run on desktop, server and embedded systems.
endef

CONFIGURE_ARGS += \
	--config=Linux \
	--no-tests \
	--no-samples \
	--no-fpenvironment \
	--no-sharedmemory \
	--no-wstring \
	--poquito \
	--minimal \
	--shared

define Package/poco/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libPoco{Foundation,XML,JSON,Net,Util}.so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/Poco $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libPoco{Foundation,XML,JSON,Net,Util}.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,poco))
