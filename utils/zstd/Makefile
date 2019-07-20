include $(TOPDIR)/rules.mk

PKG_NAME:=zstd
PKG_VERSION:=1.4.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/facebook/zstd/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=5eda3502ecc285c3c92ee0cc8cd002234dee39d539b3f692997a0e80de1d33de

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
HOST_BUILD_PARALLEL:=1
CMAKE_SOURCE_SUBDIR:=build/cmake
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/zstd/Default
	SUBMENU:=Compression
	URL:=https://github.com/facebook/zstd
endef

define Package/libzstd
$(call Package/zstd/Default)
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=zstd library.
	MENU:=1
endef

define Package/libzstd/description
	Zstandard - Fast real-time compression algorithm.
	This package provides libzstd library.
endef

define Package/libzstd/config
	config ZSTD_OPTIMIZE_O3
		bool "Use all optimizations (-O3)"
		depends on PACKAGE_libzstd
		default y
		help
			This enables additional optmizations using the -O3 compilation flag.
endef

define Package/zstd
$(call Package/zstd/Default)
	SECTION:=utils
	CATEGORY:=Utilities
	DEPENDS:=+libzstd
	TITLE:=Fast real-time compression algorithm.
endef

define Package/zstd/description
	Zstandard - Fast real-time compression algorithm.
	This package provides the zstd binaries.
endef

ifeq ($(CONFIG_ZSTD_OPTIMIZE_O3),y)
TARGET_CFLAGS:= $(filter-out -O%,$(TARGET_CFLAGS)) -O3
endif

TARGET_CFLAGS += -flto
TARGET_LDFLAGS += -Wl,--as-needed

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/libzstd.pc
	$(SED) 's,/usr/lib,$$$${prefix}/lib,g' $(1)/usr/lib/pkgconfig/libzstd.pc
endef

define Package/libzstd/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzstd.so* $(1)/usr/lib/
endef

define Package/zstd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/{unzstd,zstd,zstdcat,zstdmt} $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libzstd))
$(eval $(call BuildPackage,zstd))
$(eval $(call HostBuild))
