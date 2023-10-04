# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Paul Spooren <mail@aparcar.org>

include $(TOPDIR)/rules.mk

PKG_NAME:=liboqs
PKG_VERSION:=0.8.0
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/open-quantum-safe/liboqs/tar.gz/$(PKG_VERSION)?
PKG_HASH:=542e2d6cd4d3013bc4f97843cb1e9521b1b8d8ea72a55c9f5f040857486b0157

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DOQS_USE_OPENSSL=OFF

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/liboqs
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=PQC (Post-Quantum Cryptography) library
  DEPENDS:=+libopenssl
  URL:=https://github.com/open-quantum-safe/liboqs
endef

define Package/liboqs/description
	C library for prototyping and experimenting with quantum-resistant cryptography
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/oqs
	$(CP) $(PKG_INSTALL_DIR)/usr/include/oqs/*.h $(1)/usr/include/oqs
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liboqs.so* $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/liboqs.pc $(1)/usr/lib/pkgconfig/
endef

define Package/liboqs/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liboqs*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,liboqs))
