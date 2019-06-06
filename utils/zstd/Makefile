include $(TOPDIR)/rules.mk

PKG_NAME:=zstd
PKG_VERSION:=1.4.0
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/facebook/zstd/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=63be339137d2b683c6d19a9e34f4fb684790e864fee13c7dd40e197a64c705c1

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

ifeq ($(CONFIG_ZSTD_OPTIMIZE_O3),y)
	TARGET_CFLAGS := $(filter-out -O%,$(TARGET_CFLAGS))
	TARGET_CFLAGS += -O3
	TARGET_CXXFLAGS := $(filter-out -O%,$(TARGET_CXXFLAGS))
	TARGET_CXXFLAGS += -O3
endif

define Package/zstd/Default
	SUBMENU:=Compression
	URL:=https://github.com/facebook/zstd
endef

define Package/libzstd
$(call Package/zstd/Default)
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=zstd library.
endef

define Package/libzstd/description
	Zstandard - Fast real-time compression algorithm.
	This package provides libzstd library.
endef

define Package/libzstd/config
	config ZSTD_OPTIMIZE_O3
		bool "Use all optimizations (-O3)"
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
