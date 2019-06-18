include $(TOPDIR)/rules.mk

PKG_NAME:=fbthrift
PKG_VERSION:=2019.06.10.00
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/facebook/fbthrift/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=0897c66564a2742b24dd6ae77812b42987c3493944d1d5d40d4005d71deb7cb5

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
	-Dlib_only=ON \
	-DTHRIFT1="$(STAGING_DIR_HOSTPKG)/bin/thrift1" \
	-DTHRIFT_COMPILER_INCLUDE="$(STAGING_DIR_HOSTPKG)/include/"

define Package/fbthrift/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,fbthrift))
$(eval $(call HostBuild))
