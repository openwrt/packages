include $(TOPDIR)/rules.mk

PKG_NAME:=libwangle
PKG_VERSION:=2019.09.09.00
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/facebook/wangle/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b790ba6b975b90d7935e4ae12f84c77d6be9f9a94308a3e0b974d83cf0e01d8b
PKG_BUILD_DIR:=$(BUILD_DIR)/wangle-$(PKG_VERSION)

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=libfizz
CMAKE_SOURCE_SUBDIR:=wangle
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libwangle
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Wangle: C++ networking library
  URL:=https://github.com/facebook/wangle
endef

CMAKE_OPTIONS += \
	-DBoost_NO_BOOST_CMAKE=ON

TARGET_CXXFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

$(eval $(call BuildPackage,libwangle))
