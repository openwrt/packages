# Copyright (C) 2007-2026 OpenWrt.org
#
# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=protobuf-compat
PKG_VERSION:=3.17.3
PKG_RELEASE:=1

PKG_SOURCE:=protobuf-cpp-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/google/protobuf/releases/download/v$(PKG_VERSION)
PKG_HASH:=51cec99f108b83422b7af1170afd7aeb2dd77d2bcbb7b6bad1f92509e9ccf8cb

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:google:protobuf

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/protobuf-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/protobuf-$(PKG_VERSION)

CMAKE_SOURCE_SUBDIR:=cmake

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/protobuf-compat/Default
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A structured data encoding library (compat version)
  URL:=https://github.com/google/protobuf
  DEPENDS:=+zlib +libatomic +libstdcpp
endef

define Package/protobuf-compat
  $(call Package/protobuf-compat/Default)
  DEPENDS+=+protobuf-compat-lite
endef

define Package/protobuf-compat-lite
  $(call Package/protobuf-compat/Default)
endef

define Package/protobuf-compat/description/Default
  Protocol Buffers are a way of encoding structured data in an efficient
  yet extensible format. Google uses Protocol Buffers for almost all of its
  internal RPC protocols and file formats.
endef

define Package/protobuf-compat/description
  $(call Package/protobuf-compat/description/Default)

  This package provides the libprotoc, libprotobuf, and libprotobuf-lite
  libraries. For a much smaller protobuf package, see
  "protobuf-compat-lite".
endef

define Package/protobuf-compat-lite/description
 $(call Package/protobuf-compat/description/Default)

 This package provides the libprotobuf-lite library.
endef

# Install headers and libraries into /usr/protobuf-compat so as not to confuse
# other packages with duplicate headers, and to prevent paths conflicts with
# non-compat Protobuf.
CMAKE_HOST_OPTIONS += \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_INSTALL_INCLUDEDIR=usr/protobuf-compat/include \
	-DCMAKE_INSTALL_LIBDIR=usr/protobuf-compat/lib \
	-Dprotobuf_BUILD_PROTOC_BINARIES=ON \
	-Dprotobuf_BUILD_TESTS=OFF

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_INSTALL_PREFIX=/usr/protobuf-compat \
	-Dprotobuf_BUILD_PROTOC_BINARIES=ON \
	-Dprotobuf_BUILD_TESTS=OFF \
	-Dprotobuf_WITH_ZLIB=ON

TARGET_LDFLAGS += -latomic

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,/usr/include,$$$${prefix}/usr/protobuf-compat,g' $(1)/usr/protobuf-compat/lib/pkgconfig/protobuf.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/usr/protobuf-compat,g' $(1)/usr/protobuf-compat/lib/pkgconfig/protobuf.pc
	$(SED) 's,/usr/include,$$$${prefix}/usr/protobuf-compat,g' $(1)/usr/protobuf-compat/lib/pkgconfig/protobuf-lite.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/usr/protobuf-compat,g' $(1)/usr/protobuf-compat/lib/pkgconfig/protobuf-lite.pc
endef

define Package/protobuf-compat-lite/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/protobuf-compat/lib/libprotobuf-lite.so.* $(1)/usr/lib/
endef

define Package/protobuf-compat/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/protobuf-compat/lib/libprotobuf.so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/protobuf-compat/lib/libprotoc.so.*  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,protobuf-compat))
$(eval $(call BuildPackage,protobuf-compat-lite))
$(eval $(call HostBuild))
