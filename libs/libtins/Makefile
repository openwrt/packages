include $(TOPDIR)/rules.mk

PKG_NAME:=libtins
PKG_VERSION:=3.5
PKG_RELEASE:=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/mfontanini/libtins/archive/
PKG_HASH:=1b0624b2eea3ce077a86f3abd3e625661760c4cfd21cd8f3d3cd3622229ff2cd

PKG_MAINTAINER:=Ben Smith <le.ben.smith@gmail.com>

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_LICENSE:=BSD-2-Clause

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libtins
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libtins is a C++ network packet sniffing and crafting library
  URL:=http://libtins.github.io/
  DEPENDS:=+libpcap +libstdcpp
endef

define Package/libtins/description
libtins is a high-level, multiplatform C++ network packet sniffing and crafting library.
endef

CMAKE_OPTIONS += \
	-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
	-DLIBTINS_ENABLE_WPA2=0 \
	-DLIBTINS_ENABLE_CXX11=1 \
	-DCROSS_COMPILING=1 \
	-DCMAKE_C_COMPILER=$(TARGET_CC) \
	-DCMAKE_CXX_COMPILER=$(TARGET_CXX)

define Package/libtins/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtins.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libtins))
