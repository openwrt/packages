include $(TOPDIR)/rules.mk

PKG_NAME:=fbthrift
PKG_VERSION:=2019.10.07.00
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/facebook/fbthrift/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=91403f96a8dc49bc25791fe2836587e644d3e96c55b08e7dfe8bb0075c45a472

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_DEPENDS:=boost/host
PKG_BUILD_DEPENDS:=fbthrift/host

HOST_BUILD_PARALLEL:=1
PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/fbthrift
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Facebook's branch of Apache Thrift, including a new C++ server.
  URL:=https://github.com/facebook/fbthrift
  DEPENDS:=+libfmt +libwangle +librsocket-cpp
endef

define Package/fbthrift/description
  Facebook's branch of Apache Thrift, including a new C++ server.
endef

CMAKE_HOST_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_SKIP_RPATH=OFF \
	-DCMAKE_INSTALL_RPATH="${STAGING_DIR_HOSTPKG}/lib" \
	-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
	-Dcompiler_only=ON

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DCXX_STD=c++14 \
	-Dlib_only=ON \
	-DTHRIFT_COMPILER_INCLUDE="$(STAGING_DIR_HOSTPKG)/include/" \
	-Dpython-six_DIR=OFF

TARGET_CFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

define Package/fbthrift/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,fbthrift))
$(eval $(call HostBuild))
