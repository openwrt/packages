#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=protobuf
PKG_VERSION:=3.8.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-cpp-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/google/protobuf/releases/download/v$(PKG_VERSION)
PKG_HASH:=ddc96d83f3b7417da53bce2510b94ad2796465ef8763f7a4e82089157efe97aa

PKG_MAINTAINER:=Ken Keys <kkeys@caida.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=protobuf/host
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/protobuf/Default
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A structured data encoding library
  URL:=https://github.com/google/protobuf
  DEPENDS:=+zlib +libpthread +libatomic +libstdcpp
endef

define Package/protobuf
  $(call Package/protobuf/Default)
  DEPENDS+=+protobuf-lite
endef

define Package/protobuf-lite
  $(call Package/protobuf/Default)
endef

define Package/protobuf/description/Default
Protocol Buffers are a way of encoding structured data in an efficient
yet extensible format. Google uses Protocol Buffers for almost all
of its internal RPC protocols and file formats.
endef

define Package/protobuf/description
$(call Package/protobuf/description/Default)

This package provides the libprotoc, libprotobuf, and libprotobuf-lite
libraries.  For a much smaller protobuf package, see "protobuf-lite".

endef

define Package/protobuf-lite/description
$(call Package/protobuf/description/Default)

This package provides the libprotobuf-lite library.

endef

CONFIGURE_ARGS += --with-protoc=$(STAGING_DIR_HOSTPKG)/bin/protoc

define Build/InstallDev
	$(INSTALL_DIR) \
		$(1)/usr/lib \
		$(1)/usr/include

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/* \
		$(1)/usr/include/

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/* \
		$(1)/usr/lib/
endef

define Package/protobuf-lite/install
	$(INSTALL_DIR) \
		$(1)/usr/lib

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libprotobuf-lite.so* \
		$(1)/usr/lib/
endef

define Package/protobuf/install
	$(INSTALL_DIR) \
		$(1)/usr/lib

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libprotoc.so*  \
		$(1)/usr/lib/

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libprotobuf.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,protobuf))
$(eval $(call BuildPackage,protobuf-lite))
$(eval $(call HostBuild))
