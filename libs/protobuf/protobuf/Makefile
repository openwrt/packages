# Copyright (C) 2007-2026 OpenWrt.org
#
# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=protobuf
PKG_VERSION:=29.5
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/google/protobuf/releases/download/v$(PKG_VERSION)
PKG_HASH:=a191d2afdd75997ba59f62019425016703daed356a9d92f7425f4741439ae544

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:google:protobuf

HOST_BUILD_DEPENDS:=abseil-cpp/host
PKG_BUILD_DEPENDS:=abseil-cpp

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/protobuf/Default
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A structured data encoding library
  URL:=https://github.com/google/protobuf
  DEPENDS:=+libatomic +libstdcpp +zlib
endef

define Package/protobuf
  $(call Package/protobuf/Default)
  DEPENDS+=+libutf8-range
endef

define Package/protobuf-lite
  $(call Package/protobuf/Default)
  DEPENDS+=+libutf8-range
endef

define Package/libprotoc
  $(call Package/protobuf/Default)
  TITLE:=Protocol Buffers compiler library
  DEPENDS:=+libatomic +libstdcpp +protobuf
endef

define Package/libutf8-range
  $(call Package/protobuf/Default)
  TITLE:=UTF-8 validation libraries of Protocol Buffers
  DEPENDS:=+libatomic +libstdcpp
endef

define Package/protobuf/description/Default
  Protocol Buffers are a way of encoding structured data in an efficient
  yet extensible format. Google uses Protocol Buffers for almost all of its
  internal RPC protocols and file formats.
endef

define Package/protobuf/description
  $(call Package/protobuf/description/Default)

  This package provides the libprotobuf library. For a much smaller
  protobuf package, see "protobuf-lite". The libprotoc library is in the
  "libprotoc" package.
endef

define Package/protobuf-lite/description
 $(call Package/protobuf/description/Default)

 This package provides the libprotobuf-lite library.
endef

define Package/libprotoc/description
  $(call Package/protobuf/description/Default)

  This package provides the libprotoc library, which the protoc compiler
  and its plugins use. Programs that only read and write messages do not
  need it.
endef

define Package/libutf8-range/description
  This package provides the libutf8_range and libutf8_validity libraries,
  which are built with Protocol Buffers and used by libprotobuf and
  libprotobuf-lite.
endef

CMAKE_HOST_OPTIONS += \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-Dprotobuf_ABSL_PROVIDER="package" \
	-Dprotobuf_BUILD_EXAMPLES=OFF \
	-Dprotobuf_BUILD_PROTOC_BINARIES=ON \
	-Dprotobuf_BUILD_TESTS=OFF

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-Dprotobuf_ABSL_PROVIDER="package" \
	-Dprotobuf_BUILD_EXAMPLES=OFF \
	-Dprotobuf_BUILD_PROTOC_BINARIES=ON \
	-Dprotobuf_BUILD_TESTS=OFF \
	-Dprotobuf_WITH_ZLIB=ON

TARGET_LDFLAGS += -latomic

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/protobuf.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/protobuf.pc
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/protobuf-lite.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/protobuf-lite.pc
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/upb.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/upb.pc
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/utf8_range.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/utf8_range.pc
endef

define Package/protobuf-lite/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libprotobuf-lite.so.* $(1)/usr/lib/
endef

define Package/protobuf/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libprotobuf.so.* $(1)/usr/lib/
endef

define Package/libprotoc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libprotoc.so.* $(1)/usr/lib/
endef

define Package/libutf8-range/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libutf8_range.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libutf8_validity.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,protobuf))
$(eval $(call BuildPackage,protobuf-lite))
$(eval $(call BuildPackage,libprotoc))
$(eval $(call BuildPackage,libutf8-range))
$(eval $(call HostBuild))
