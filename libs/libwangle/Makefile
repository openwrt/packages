include $(TOPDIR)/rules.mk

PKG_NAME:=libwangle
PKG_VERSION:=2019.08.12.00
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/facebook/wangle
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=d9c48956d4ebf230c03191cd7a6f200d14da1c5c411ded6b27745ca7e95c06e4

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
  URL:=https://github.com/facebook/wangle
  DEPENDS:=+libfizz
endef

define Package/libwangle/description
	Wangle is a framework providing a set of common client/server abstractions for building services in a consistent, modular, and composable way.
	This package includes the shared library.
endef

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON

TARGET_CXXFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

define Package/libwangle/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwangle.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libwangle))
