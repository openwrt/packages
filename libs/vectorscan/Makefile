#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vectorscan
PKG_VERSION:=5.4.12
PKG_RELEASE:=1

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

define Package/vectorscan-headers
  CATEGORY:=Libraries
  SECTION:=libs
  TITLE:=Vectorscan Headers
  URL:=https://github.com/VectorCamp/vectorscan
  DEPENDS:=@(x86_64||aarch64)
endef

define Package/vectorscan-runtime
  CATEGORY:=Libraries
  SECTION:=libs
  TITLE:=Vectorscan Runtime
  URL:=https://github.com/VectorCamp/vectorscan
  DEPENDS:= +libstdcpp +libsqlite3 @(x86_64||aarch64)
endef

define Package/vectorscan-headers/description
  This package contains the headers for Vectorscan.
  A fork of Intel's Hyperscan, modified to run on more platforms.
endef

define Package/vectorscan-runtime/description
  This package contains the shared objects for Vectorscan.
  A fork of Intel's Hyperscan, modified to run on more platforms.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/hs
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/hs/* $(1)/usr/include/hs/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhs* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/libhs.pc $(1)/usr/lib/pkgconfig/libhs.pc
endef

define Package/vectorscan-headers/install
	$(INSTALL_DIR) $(1)/usr/include/hs
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/hs/*.h $(1)/usr/include/hs/
endef

define Package/vectorscan-runtime/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhs* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,vectorscan-headers))
$(eval $(call BuildPackage,vectorscan-runtime))
