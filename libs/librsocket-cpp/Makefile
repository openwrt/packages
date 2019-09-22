include $(TOPDIR)/rules.mk

PKG_NAME:=librsocket-cpp
PKG_SOURCE_DATE:=2019-09-22
PKG_SOURCE_VERSION:=b268907312af589828634c143b9f35b58cd6cfea
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rsocket/rsocket-cpp/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=7ab4655d3d8148ce689f74a116ae7393d9e802f91d0dfd697ffd8daeff800e61
PKG_BUILD_DIR:=$(BUILD_DIR)/rsocket-cpp-$(PKG_SOURCE_VERSION)

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
CMAKE_BINARY_SUBDIR:=builddir
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/librsocket-cpp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=C++ implementation of RSocket
  URL:=https://rsocket.io/
  DEPENDS:=+libyarpl
endef

define Package/libyarpl
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=yarpl: Yet Another Reactive Programming Library
  URL:=https://rsocket.io/
  DEPENDS:=+libfolly
endef

define Package/librsocket-cpp/description
  C++ implementation of RSocket, and Application protocol providing Reactive Streams semantics
endef

define Package/libyarpl/description
  C++ implementation of reactive functional programming including both Observable and Flowable types.
endef

CMAKE_OPTIONS += \
	-DBUILD_BENCHMARKS=OFF \
	-DBUILD_EXAMPLES=OFF \
	-DBUILD_TESTS=OFF \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON

$(eval $(call BuildPackage,librsocket-cpp))
$(eval $(call BuildPackage,libyarpl))
