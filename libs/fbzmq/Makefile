include $(TOPDIR)/rules.mk

PKG_NAME:=fbzmq
PKG_VERSION:=2019.07.22.00
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/facebook/fbzmq
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=c249e2269dbd16cb455fb7b1ea226f2158d1f3dae9cd0c490e89356db1066b7a

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
CMAKE_SOURCE_SUBDIR:=fbzmq
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/fbzmq
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=Facebook ZeroMQ wrappers.
	DEPENDS:=+fbthrift +libzmq +libsigar
endef

define Package/fbzmq/description
	Facebook ZeroMQ wrappers.
endef

CMAKE_OPTIONS += \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DBUILD_TESTS=OFF \
	-DBUILD_SHARED_LIBS=ON \
	-DTHRIFT1="$(STAGING_DIR_HOSTPKG)/bin/thrift1" \
	-DTHRIFT_COMPILER_INCLUDE="$(STAGING_DIR_HOSTPKG)/include/"

TARGET_CXXFLAGS += -faligned-new

define Package/fbzmq/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfbzmq.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,fbzmq))
