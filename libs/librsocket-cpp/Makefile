include $(TOPDIR)/rules.mk

PKG_NAME:=librsocket-cpp
PKG_SOURCE_DATE:=2019-06-11
PKG_SOURCE_VERSION:=741f817fd519e0610cddb5783aae812355e19435
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rsocket/rsocket-cpp/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=56886deba0f3594b4a430b1f515c90a138800b8e387440e6b8bf728d660f457a
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
	-DBUILD_TESTS=OFF \
	-DBUILD_SHARED_LIBS=ON

define Package/librsocket-cpp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libReactiveSocket.so* $(1)/usr/lib/
endef

define Package/libyarpl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libyarpl*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,librsocket-cpp))
$(eval $(call BuildPackage,libyarpl))
