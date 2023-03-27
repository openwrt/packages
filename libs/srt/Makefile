# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Koen Vandeputte <koen.vandeputte@citymesh.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=srt
PKG_VERSION:=1.5.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/haivision/srt/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=befaeb16f628c46387b898df02bc6fba84868e86a6f6d8294755375b9932d777
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Koen Vandeputte <koen.vandeputte@citymesh.com>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_libstdcpp \
	CONFIG_PACKAGE_libatomic

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/srt
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=secure reliable transport
  URL:=https://github.com/Haivision/srt
  DEPENDS:=+libstdcpp +libatomic +SRT_OPENSSL_SUPPORT:libopenssl
endef

define Package/srt/description
 This package contains a library for srt streaming.
endef

define Package/srt/config
	source "$(SOURCE)/Config.in"
endef

ifdef CONFIG_SRT_OPENSSL_SUPPORT
	CMAKE_OPTIONS += \
		-DENABLE_ENCRYPTION=ON
		-DOPENSSL_USE_STATIC_LIBS=OFF
else
	CMAKE_OPTIONS += -DENABLE_ENCRYPTION=OFF
endif

CMAKE_OPTIONS += \
	-DENABLE_MONOTONIC_CLOCK=ON \
	-DENABLE_APPS=OFF \
	-DENABLE_STATIC=OFF \
	-DENABLE_STDCXX_SYNC=OFF

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/srt.pc $(1)/usr/lib/pkgconfig/
endef

define Package/srt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsrt.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,srt))
