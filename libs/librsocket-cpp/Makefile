include $(TOPDIR)/rules.mk

PKG_NAME:=librsocket-cpp
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rsocket/rsocket-cpp
PKG_SOURCE_DATE:=2019-07-22
PKG_SOURCE_VERSION:=4658d346b2aa190b2326652186ecf92020e2c3da
PKG_MIRROR_HASH:=9a819e3235a1819e9d6f9ec8c61e4d3a5a59b4380c12d47d644c49d0652bc922

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
