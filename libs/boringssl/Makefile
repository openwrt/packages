# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2021 Martin Schneider <martschneider@google.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=boringssl
PKG_VERSION:=20210608
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://boringssl.googlesource.com/boringssl
PKG_SOURCE_DATE:=2021-06-08
PKG_SOURCE_VERSION:=1f54fd9864c054dc33e15b1144e2a6a19fa0a52e
PKG_MIRROR_HASH:=d69c6437981471451dc699742bb06a022579de1a63906c9fe398aae053fc33bf

PKG_MAINTAINER:=Martin Schneider <martschneider@google.com>
PKG_LICENSE:=OpenSSL ISC
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:google:boringssl

PKG_BUILD_DEPENDS:=golang/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include ../../lang/golang/golang-values.mk

define Package/boringssl
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=An implementation of the TLS protocol
	URL:=https://boringssl.googlesource.com/boringssl/
	DEPENDS:=+libstdcpp $(GO_ARCH_DEPENDS) @!(mips||mips64)
endef

define Package/boringssl/description
	An implementation of the TLS protocol
endef

CMAKE_OPTIONS+=-DBUILD_SHARED_LIBS=ON

define Package/boringssl/install
	$(INSTALL_DIR) $(1)/usr/lib/boringssl
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/bin/lib{crypto,ssl}.so $(1)/usr/lib/boringssl
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/boringssl
	$(INSTALL_DIR) $(1)/usr/include/boringssl
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/lib{crypto,ssl}.so $(1)/usr/lib/boringssl
	$(CP) $(PKG_BUILD_DIR)/include/* $(1)/usr/include/boringssl
endef

$(eval $(call BuildPackage,boringssl))
