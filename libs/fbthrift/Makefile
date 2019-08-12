include $(TOPDIR)/rules.mk

PKG_NAME:=fbthrift
PKG_SOURCE_DATE:=2019-09-03
PKG_SOURCE_VERSION:=efd9d0d0d5301c9bcca0fd0e4f64219a04970431
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/facebook/fbthrift/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=f902279b1f9f9c6b714abd63d2327957072982ed262ff6fd997b2f2f955eb05c
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_DEPENDS:=libmstch/host
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
  DEPENDS:=+libwangle +libfmt +librsocket-cpp
endef

define Package/fbthrift/description
  Facebook's branch of Apache Thrift, including a new C++ server.
endef

CMAKE_HOST_OPTIONS += \
	-DBoost_NO_BOOST_CMAKE=ON \
	-DCMAKE_SKIP_RPATH=FALSE \
	-DCMAKE_INSTALL_RPATH="${STAGING_DIR_HOSTPKG}/lib" \
	-Dcompiler_only=ON

CMAKE_OPTIONS += \
	-DBoost_NO_BOOST_CMAKE=ON \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DCXX_STD=c++14 \
	-Dlib_only=ON \
	-DTHRIFT1="$(STAGING_DIR_HOSTPKG)/bin/thrift1" \
	-DTHRIFT_COMPILER_INCLUDE="$(STAGING_DIR_HOSTPKG)/include/"

define Package/fbthrift/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,fbthrift))
$(eval $(call HostBuild))
