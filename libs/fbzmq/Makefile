include $(TOPDIR)/rules.mk

PKG_NAME:=fbzmq
PKG_VERSION:=2019.10.07.00
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/facebook/fbzmq/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=41b6c671dd1cd16eeffa94f146c8a6841c8a05e0517d8affc96dde8324af11af

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/fbzmq
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Facebook ZeroMQ wrappers.
  URL:=https://github.com/facebook/fbzmq
  DEPENDS:=+libfolly +libzmq +libsigar +fbthrift
endef

define Package/fbzmq/description
  Facebook ZeroMQ wrappers.
endef

CMAKE_OPTIONS += \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_TESTS=OFF \
	-DFBTHRIFT_COMPILER="$(STAGING_DIR_HOSTPKG)/bin/thrift1"

TARGET_CXXFLAGS += -faligned-new
TARGET_CXXFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

define Package/fbzmq/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfbzmq.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,fbzmq))
