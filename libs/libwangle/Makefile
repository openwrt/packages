include $(TOPDIR)/rules.mk

PKG_NAME:=libwangle
PKG_VERSION:=2019.06.10.00
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/facebook/wangle/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=3721c003aa5fce889699b0301705eced7a0ea4ab2e7e12af543dab3493ba8be9
PKG_BUILD_DIR:=$(BUILD_DIR)/wangle-$(PKG_VERSION)

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
CMAKE_SOURCE_SUBDIR:=wangle
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libwangle
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=Wangle: C++ networking library
	DEPENDS:=+libfizz
endef

define Package/libwangle/description
	Wangle is a framework providing a set of common client/server abstractions for building services in a consistent, modular, and composable way.
	This package includes the shared library.
endef

CMAKE_OPTIONS:= \
	-DBUILD_SHARED_LIBS=ON

define Package/libwangle/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwangle.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libwangle))
