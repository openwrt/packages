include $(TOPDIR)/rules.mk

PKG_NAME:=libwangle
PKG_VERSION:=2019.10.07.00
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/facebook/wangle/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b030fbff5f346ba4e50e97fc452b321f1f32b215ba7a31e1538c2996b76cf1e9
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
  URL:=https://github.com/facebook/wangle
  DEPENDS:=+libfizz
endef

TARGET_CXXFLAGS += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON

define Package/libwangle/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwangle.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libwangle))
