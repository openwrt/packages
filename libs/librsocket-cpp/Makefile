include $(TOPDIR)/rules.mk

PKG_NAME:=librsocket-cpp
PKG_SOURCE_DATE:=2019-05-08
PKG_SOURCE_VERSION:=ddc80392b17a3fadcbea09f82ea5f6936f0fd459
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rsocket/rsocket-cpp/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=b9b5177be57f6cd23ff3592845b11209167f679b683cb73acbf351e7a3550a76
PKG_BUILD_DIR:=$(BUILD_DIR)/rsocket-cpp-$(PKG_SOURCE_VERSION)

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

PKG_BUILD_PARALLEL:=1
CMAKE_BINARY_SUBDIR:=builddir
CMAKE_OPTIONS:= \
	-DBUILD_BENCHMARKS=OFF \
	-DBUILD_EXAMPLES=OFF \
	-DBUILD_TESTS=OFF \
	-DBUILD_SHARED_LIBS=ON
CMAKE_INSTALL:=1

define Package/librsocket-cpp
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=C++ implementation of RSocket
	DEPENDS:=+libfolly +gflags +glog +libopenssl +libyarpl
endef

define Package/libyarpl
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=yarpl: Yet Another Reactive Programming Library
	DEPENDS:=+libfolly +gflags +glog +libatomic
endef

define Package/librsocket-cpp/description
	C++ implementation of RSocket, and Application protocol providing Reactive Streams semantics
endef

define Package/libyarpl/description
	C++ implementation of reactive functional programming including both Observable and Flowable types.
endef

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
