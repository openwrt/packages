# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=libepoxy
PKG_VERSION:=1.5.3
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/anholt/libepoxy/releases/download/$(PKG_VERSION)/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=002958c5528321edd53440235d3c44e71b5b1e09b9177e8daf677450b6c4433d

PKG_BUILD_DEPENDS:=util-macros python
#PKG_FIXUP:=autoreconf
PKG_FIXUP:=libtool

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libepoxy
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+mesa +libx11
  TITLE:=Direct Rendering Manager runtime library
  URL:=https://github.com/anholt/libepoxy
endef

CONFIGURE_ARGS += \
  --prefix=/usr \
  --disable-static \
  --enable-shared

define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include/* \
	  $(1)/usr/include/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
	  $(1)/usr/lib/
endef

define Package/libepoxy/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
	  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libepoxy))
