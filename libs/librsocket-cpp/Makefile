include $(TOPDIR)/rules.mk

PKG_NAME:=librsocket-cpp
PKG_SOURCE_DATE:=2019-10-07
PKG_SOURCE_VERSION:=0a469f7a84d9e3c3ddcb6931df701a5dae536589
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rsocket/rsocket-cpp/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=c10e498039d676946a11f6a45201575cdb3f1f582752693d7b1901aa434f3146
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
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_TESTS=OFF \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON

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
