#
# Copyright (C) 2007-2016 OpenWrt.org
# Copyright (C) 2017 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=poco
PKG_RELEASE:=2
PKG_VERSION:=1.9.0

ifeq ($(BUILD_VARIANT),all)
_PKG_VERSION:=${PKG_VERSION}-all
PKG_HASH:=b6e33898588e74337efec4e8d8b9b277bb653b08318a79215f9aa4a3ff1ea9fd
else
_PKG_VERSION:=${PKG_VERSION}
PKG_HASH:=a0a5a03d87c585f1a43def33bfc52c0c34a528e43a7b13bc83841a7c00adde39
endif

PKG_SOURCE:=$(PKG_NAME)-$(_PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://pocoproject.org/releases/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=BSL-1.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:pocoproject:poco

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(_PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/poco
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Poco C++ libraries
  URL:=https://www.pocoproject.org/
  DEPENDS:=+libstdcpp +libpthread +librt @!arc
  MAINTAINER:=Jean-Michel Julien <jean-michel.julien@trilliantinc.com>
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
  DEPENDS+=+libopenssl
  VARIANT:=all
endef

define Package/poco-all/description
  POrtable COmponents, a modern and powerful open source C++ class libraries
  and frameworks for building network and internet-based applications that
  run on desktop, server and embedded systems. The Complete Edition contains
  all libraries.
endef

CONFIGURE_ARGS += \
	--config=Linux \
	--no-tests \
	--no-samples \
	--no-fpenvironment \
	--no-sharedmemory \
	--no-wstring \
	--shared

ifeq ($(BUILD_VARIANT),all)
	CONFIGURE_ARGS += \
		--typical
	POCO_LIBS={Foundation,XML,JSON,Net,Util,Crypto,NetSSL,Encodings}
else
	CONFIGURE_ARGS += \
		--poquito \
		--minimal
	POCO_LIBS={Foundation,XML,JSON,Net,Util}
endif

define Package/poco/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libPoco$(POCO_LIBS).so* $(1)/usr/lib/
endef

define Package/poco-all/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libPoco$(POCO_LIBS).so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/Poco $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libPoco$(POCO_LIBS).so* $(1)/usr/lib/
endef


$(eval $(call BuildPackage,poco))
$(eval $(call BuildPackage,poco-all))
