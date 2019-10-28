# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=libjpeg-turbo
PKG_VERSION:=2.0.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=@SF/libjpeg-turbo
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=e5f86cec31df1d39596e0cca619ab1b01f99025a27dafdfc97a30f3a12f866ff

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
CMAKE_INSTALL=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libjpeg-turbo
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=
  TITLE:=accelerated baseline JPEG compression and decompression library
  URL:=https://libjpeg-turbo.org/
  PROVIDES:=libjpeg
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

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

define Package/libjpeg-turbo/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
	  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libjpeg-turbo))
