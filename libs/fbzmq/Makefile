include $(TOPDIR)/rules.mk

PKG_NAME:=fbzmq
PKG_VERSION:=2019.06.10.00
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/facebook/fbzmq/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=9bb9b2bd42951fa3458b5d6d25f3364c14a7efa3b78bef68a6c00ee6fcba5813

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

CMAKE_SOURCE_SUBDIR:=fbzmq
PKG_BUILD_DEPENDS:=fbthrift
PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/fbzmq
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Facebook ZeroMQ wrappers.
  URL:=https://github.com/facebook/fbzmq
  DEPENDS:=+libfolly +libzmq +libsigar
endef

define Package/fbzmq/description
  Facebook ZeroMQ wrappers.
endef

CMAKE_OPTIONS += \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DBUILD_TESTS=OFF \
	-DTHRIFT1="$(STAGING_DIR_HOSTPKG)/bin/thrift1" \
	-DTHRIFT_COMPILER_INCLUDE="$(STAGING_DIR_HOSTPKG)/include/"

TARGET_CXXFLAGS += -faligned-new
TARGET_CXXFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

$(eval $(call BuildPackage,fbzmq))
