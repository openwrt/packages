include $(TOPDIR)/rules.mk

PKG_NAME:=fbthrift
PKG_SOURCE_DATE:=2019-09-22
PKG_SOURCE_VERSION:=2f9839604e2569120cc4876c667388da6d7342f2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/facebook/fbthrift/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=339a73610ad19070d33151127966aaf56e5df3640c238292fc74658c3075da3a
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_DEPENDS:=libmstch/host
PKG_BUILD_DEPENDS:=fbthrift/host libwangle librsocket-cpp

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
  DEPENDS:=+libfmt +libfolly
endef

define Package/fbthrift/description
  Facebook's branch of Apache Thrift, including a new C++ server.
endef

CMAKE_HOST_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_SKIP_RPATH=OFF \
	-DCMAKE_INSTALL_RPATH="${STAGING_DIR_HOSTPKG}/lib" \
	-Dcompiler_only=ON

CMAKE_OPTIONS += \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DCXX_STD=c++14 \
	-Dlib_only=ON \
	-DTHRIFT1="$(STAGING_DIR_HOSTPKG)/bin/thrift1" \
	-DTHRIFT_COMPILER_INCLUDE="$(STAGING_DIR_HOSTPKG)/include/" \
	-Dpython-six_DIR=OFF

# This should not be necessary as it is supposed to be done above.
# Someone broke something.
HOST_LDFLAGS += -Wl,-rpath="$(STAGING_DIR_HOSTPKG)/lib"

# GCC9 bug
TARGET_LDFLAGS += -fno-lto

TARGET_CFLAGS += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

$(eval $(call BuildPackage,fbthrift))
$(eval $(call HostBuild))
