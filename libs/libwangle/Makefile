include $(TOPDIR)/rules.mk

PKG_NAME:=libwangle
PKG_VERSION:=2019.05.06.00
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/facebook/wangle/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=de145e3748a5f71be1883ad2ea4be37e99f99fcb1838a6a258ca2c4cd0d053e7
PKG_BUILD_DIR:=$(BUILD_DIR)/wangle-$(PKG_VERSION)

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

PKG_BUILD_PARALLEL:=1
CMAKE_SOURCE_SUBDIR:=wangle
CMAKE_OPTIONS:= \
	-DBUILD_SHARED_LIBS=ON
CMAKE_INSTALL:=1

define Package/libwangle
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=Wangle: C++ networking library
	DEPENDS:=+libstdcpp +libfolly +libsodium +libfizz
endef

define Package/libwangle/description
	Wangle is a framework providing a set of common client/server abstractions for building services in a consistent, modular, and composable way.
	This package includes the shared library.
endef

define Package/libwangle/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwangle.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libwangle))
