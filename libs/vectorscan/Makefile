#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vectorscan
PKG_VERSION:=5.4.12
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/VectorCamp/vectorscan/tar.gz/$(PKG_NAME)/$(PKG_VERSION)?
PKG_HASH:=1ac4f3c038ac163973f107ac4423a6b246b181ffd97fdd371696b2517ec9b3ed
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=BSD-3-Clause BSD-2-Clause BSL-1.0
PKG_LICENSE_FILES:=LICENSE
CMAKE_INSTALL:=1
PKG_BUILD_FLAGS:=no-lto
PKG_BUILD_DEPENDS:=ragel/host python3/host boost/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# With at least version 5.4.12, Neon/ASIMD is required for Arm support
ifeq ($(CONFIG_CPU_NEON),)
  PKG_BUILD_FLAGS := skip
endif

CMAKE_OPTIONS += \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DBUILD_SHARED_LIBS=ON \
	-Wno-dev

ifeq ($(CONFIG_USE_GLIBC),y)
	CMAKE_OPTIONS += -DFAT_RUNTIME=ON -DBUILD_BENCHMARKS=ON
else
	CMAKE_OPTIONS += -DFAT_RUNTIME=OFF -DBUILD_BENCHMARKS=OFF
endif

define Package/vectorscan
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Vectorscan Runtime
  URL:=https://github.com/VectorCamp/vectorscan
  DEPENDS:= +libstdcpp +libsqlite3 @(x86_64||aarch64)
  ABI_VERSION:=5
endef

define Package/vectorscan/description
  Vectorscan is a portable fork of Intel's Hyperscan, a high-performance
  multiple regex matching library. It provides a streaming and block-based
  regex matcher with support for large pattern sets.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/hs
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/hs/* $(1)/usr/include/hs/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhs* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/libhs.pc $(1)/usr/lib/pkgconfig/libhs.pc
endef

define Package/vectorscan/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhs.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,vectorscan))
