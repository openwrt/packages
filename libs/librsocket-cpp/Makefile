include $(TOPDIR)/rules.mk

PKG_NAME:=librsocket-cpp
PKG_SOURCE_DATE:=2019-08-12
PKG_SOURCE_VERSION:=ffe9a1e9c7583f8081e5d4d11a3b2fc68867677d
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rsocket/rsocket-cpp
PKG_MIRROR_HASH:=13f89eec56d0617823857e48ed5806988c90cc1443822814e616086d42b81e17

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
	URL:=https://rsocket.io
	DEPENDS:=+libyarpl
endef

define Package/libyarpl
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=yarpl: Yet Another Reactive Programming Library
	URL:=https://rsocket.io
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

TARGET_CXXFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

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
