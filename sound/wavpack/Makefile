include $(TOPDIR)/rules.mk

PKG_NAME:=wavpack
PKG_VERSION:=5.7.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.wavpack.com/
PKG_HASH:=e81510fd9ec5f309f58d5de83e9af6c95e267a13753d7e0bbfe7b91273a88bee

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=BSD-3c
PKG_LICENSE_FILES:=COPYING LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += -DBUILD_SHARED_LIBS=ON

CMAKE_BINARY_SUBDIR:=openwrt-build

define Package/libwavpack
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=Hybrid Lossless Audio Compression
  URL:=https://www.wavpack.com/
endef

define Package/libwavpack/description
  WavPack is a completely open audio compression format providing lossless,
  high-quality lossy, and a unique hybrid compression mode.
endef

define Package/libwavpack/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libwavpack))
