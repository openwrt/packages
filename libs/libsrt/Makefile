# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Koen Vandeputte <koen.vandeputte@citymesh.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=libsrt
PKG_VERSION:=1.5.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Haivision/srt.git
PKG_SOURCE_VERSION:=0bc3b03202b3159fc9b085b3ae6d66ec071c25d6
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=665cc238a774e0d938195276e1cbff26950ed216606e69e94d192c522337219c

PKG_MAINTAINER:=Koen Vandeputte <koen.vandeputte@citymesh.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_libopenssl \
	CONFIG_PACKAGE_libatomic \
	CONFIG_PACKAGE_libstdcpp

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CRYPTO_DEPENDS:=

CMAKE_OPTIONS += \
	-DENABLE_MONOTONIC_CLOCK=ON \
	-DENABLE_APPS=OFF \
	-DENABLE_STATIC=OFF \
	-DENABLE_STDCXX_SYNC=OFF \
	-DENABLE_ENCRYPTION=OFF

define Package/libsrt
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=secure reliable transport
  URL:=https://github.com/Haivision/srt
  DEPENDS:=+libstdcpp +libatomic $(CRYPTO_DEPENDS)
endef

define Package/libsrt/description
 This package contains a library for srt streaming.
endef

define Package/libsrt/config
        source "$(SOURCE)/Config.in"
endef

ifdef CONFIG_LIBSRT_OPENSSL_SUPPORT
	CMAKE_OPTIONS += -DENABLE_ENCRYPTION=ON
	CRYPTO_DEPENDS := +libopenssl
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/srt.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libsrt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsrt.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libsrt))
