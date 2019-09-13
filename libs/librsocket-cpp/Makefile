include $(TOPDIR)/rules.mk

PKG_NAME:=librsocket-cpp
PKG_SOURCE_DATE:=2019-09-12
PKG_SOURCE_VERSION:=9226988e3da89eff8cd55952ccae61fcac0881fa
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rsocket/rsocket-cpp/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=3273012c1ffa149fddfac2b547315834e9a02ff0d8d1357196fec95391150ed6
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
  DEPENDS:=+libyarpl
endef

define Package/libyarpl
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=yarpl: Yet Another Reactive Programming Library
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
	-DBUILD_TESTS=OFF

$(eval $(call BuildPackage,librsocket-cpp))
$(eval $(call BuildPackage,libyarpl))
