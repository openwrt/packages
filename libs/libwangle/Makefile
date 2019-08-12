include $(TOPDIR)/rules.mk

PKG_NAME:=libwangle
PKG_VERSION:=2019.09.22.00
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_VERSION:=fb79e25af6d4e184587b62475fb3444643ae8867
PKG_SOURCE_URL:=https://codeload.github.com/facebook/wangle/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=e973cad492d025c93af49c245b1f77b484df09a4d70ade069648d633d5a85e0e
PKG_BUILD_DIR:=$(BUILD_DIR)/wangle-$(PKG_SOURCE_VERSION)

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

TARGET_CXXFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

$(eval $(call BuildPackage,libwangle))
