include $(TOPDIR)/rules.mk

PKG_NAME:=fastfetch
PKG_VERSION:=2.63.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/fastfetch-cli/fastfetch/archive/refs/tags
PKG_HASH:=6e124699ea20fb02c5bc402c0012543303ee75ca55ad664f96bc6cd414d7e6b3

PKG_MAINTAINER:=Albrecht Lohofener <albrecht@albrechtloh.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:fastfetch-cli:fastfetch
PKG_BUILD_PARALLEL:=1

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/fastfetch
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Fast neofetch-like system information tool
  URL:=https://github.com/fastfetch-cli/fastfetch
endef

define Package/fastfetch/description
 Fastfetch is a neofetch-like tool for fetching system information
 and displaying it in a visually appealing way.
endef

CMAKE_OPTIONS += \
	-DBUILD_TESTS=OFF \
	-DBUILD_FLASHFETCH=OFF \
	-DSET_TWEAK=OFF \
	-DENABLE_IMAGEMAGICK6=OFF \
	-DENABLE_IMAGEMAGICK7=OFF \
	-DENABLE_CHAFA=OFF \
	-DENABLE_OPENCL=OFF \
	-DENABLE_FREETYPE=OFF \
	-DENABLE_LUA=OFF \
	-DENABLE_QUICKJS=OFF \
	-DENABLE_PULSE=OFF \
	-DENABLE_DDCUTIL=OFF \
	-DENABLE_EMBEDDED_PCIIDS=OFF \
	-DENABLE_EMBEDDED_AMDGPUIDS=OFF

define Package/fastfetch/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fastfetch $(1)/usr/bin/
endef

$(eval $(call BuildPackage,fastfetch))