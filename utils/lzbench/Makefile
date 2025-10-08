include $(TOPDIR)/rules.mk

PKG_NAME:=lzbench
PKG_VERSION:=2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/inikep/lzbench/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=f86186864d4de6fdb187e34ddb5426f9c4910861726413fcba55eae65ef5a25b

PKG_MAINTAINER:=Nikita Solianik <gxcreator@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later BSD-3-Clause MIT Zlib
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lzbench
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Compression
  TITLE:=In-memory benchmark for compression algorithms
  URL:=https://github.com/inikep/lzbench
  DEPENDS:=+libstdcpp +libpthread
endef

define Package/lzbench/description
  lzbench is an in-memory benchmark for open-source compression algorithms.
  It integrates multiple compression libraries into a single executable and
  allows for easy comparison of compression speed, decompression speed, and
  compression ratio.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(MAKE_FLAGS)
endef

TARGET_CFLAGS := $(filter-out -O%,$(TARGET_CFLAGS))

MAKE_FLAGS += \
	CXX="$(TARGET_CXX)" \
	CC="$(TARGET_CC)" \
	USER_CFLAGS="$(TARGET_CFLAGS)" \
	USER_CPPFLAGS="$(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	BUILD_STATIC=0 \
	DONT_BUILD_BRIEFLZ=1 \
	DONT_BUILD_BSC=1 \
	DONT_BUILD_BZIP3=1 \
	DONT_BUILD_CRUSH=1 \
	DONT_BUILD_CSC=1 \
	DONT_BUILD_DENSITY=1 \
	DONT_BUILD_FASTLZMA2=1 \
	DONT_BUILD_GIPFELI=1 \
	DONT_BUILD_GLZA=1 \
	DONT_BUILD_KANZI=1 \
	DONT_BUILD_LIBDEFLATE=1 \
	DONT_BUILD_LIZARD=1 \
	DONT_BUILD_LZF=1 \
	DONT_BUILD_LZFSE=1 \
	DONT_BUILD_LZG=1 \
	DONT_BUILD_LZHAM=1 \
	DONT_BUILD_LZLIB=1 \
	DONT_BUILD_LZMAT=1 \
	DONT_BUILD_LZO=1 \
	DONT_BUILD_LZRW=1 \
	DONT_BUILD_LZSSE=1 \
	DONT_BUILD_NVCOMP=1 \
	DONT_BUILD_QUICKLZ=1 \
	DONT_BUILD_PPMD=1 \
	DONT_BUILD_SNAPPY=1 \
	DONT_BUILD_SLZ=1 \
	DONT_BUILD_TAMP=1 \
	DONT_BUILD_TORNADO=1 \
	DONT_BUILD_UCL=1 \
	DONT_BUILD_WFLZ=1 \
	DONT_BUILD_YAPPY=1 \
	DONT_BUILD_ZLING=1 \
	DONT_BUILD_ZPAQ=1

define Package/lzbench/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lzbench $(1)/usr/bin/
endef

$(eval $(call BuildPackage,lzbench))
