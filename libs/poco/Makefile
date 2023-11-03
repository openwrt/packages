#
# Copyright (C) 2007-2016 OpenWrt.org
# Copyright (C) 2017 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=poco
PKG_VERSION:=1.11.0
PKG_RELEASE:=2

ifeq ($(BUILD_VARIANT),all)
_PKG_VERSION:=${PKG_VERSION}-all
PKG_HASH:=b08cf73926fa92a6c8f3c712e8fb217d5d0c2fa5248ec0281f251fe1e925d2f1
else
_PKG_VERSION:=${PKG_VERSION}
PKG_HASH:=06ddc4934ff0a11be425d697f861c15b43b77b610e3642a2f85d0c34d7425ea4
endif

PKG_SOURCE:=$(PKG_NAME)-$(_PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://pocoproject.org/releases/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(_PKG_VERSION)

PKG_MAINTAINER:=Jean-Michel Julien <jean-michel.julien@trilliantinc.com>
PKG_LICENSE:=BSL-1.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:pocoproject:poco

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/poco
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Poco C++ libraries
  URL:=https://www.pocoproject.org/
  DEPENDS:=+libstdcpp +libpthread +librt @!arc
  VARIANT:=minimal
endef

define Package/poco/description
  POrtable COmponents, a modern and powerful open source C++ class libraries
  and frameworks for building network and internet-based applications that
  run on desktop, server and embedded systems.
endef

define Package/poco-all
  $(call Package/poco)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+=(Complete Edition)
  DEPENDS+=+libopenssl +libmariadb +libpq +unixodbc
  VARIANT:=all
endef

define Package/poco-all/description
  POrtable COmponents, a modern and powerful open source C++ class libraries
  and frameworks for building network and internet-based applications that
  run on desktop, server and embedded systems. The Complete Edition contains
  all libraries.
endef

define Package/poco/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libPoco*.so* $(1)/usr/lib/
endef

define Package/poco-all/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libPoco*.so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/Poco $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libPoco*.so* $(1)/usr/lib/
endef


$(eval $(call BuildPackage,poco))
$(eval $(call BuildPackage,poco-all))
