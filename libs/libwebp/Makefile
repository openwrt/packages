include $(TOPDIR)/rules.mk

PKG_NAME:=libwebp
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://storage.googleapis.com/downloads.webmproject.org/releases/webp
PKG_HASH:=e20a07865c8697bba00aebccc6f54912d6bc333bb4d604e6b07491c1a226b34f

PKG_MAINTAINER:=
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/libwebp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=WebP library
  URL:=https://www.webmproject.org
endef

define Package/libwebp/description
  The libwebp package contains a library for the WebP format.
endef

CONFIGURE_ARGS += \
	--enable-shared \
	--disable-static \
	--disable-neon-rtcd \
	--disable-gl \
	--disable-sdl \
	--disable-gif \
	--disable-jpeg \
	--disable-png \
	--disable-tiff \
	--disable-wic \
	--disable-libwebpmux \
	--disable-libwebpdemux \
	--disable-libwebpdecoder \
	--disable-libwebpextras \
	--without-pic

TARGET_CFLAGS += $(FPIC) -flto

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/webp
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/webp/* $(1)/usr/include/webp/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwebp* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libwebp.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libwebp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwebp.s* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libwebp))
