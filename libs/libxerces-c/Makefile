#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=xerces-c
PKG_VERSION:=3.2.2
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@APACHE/xerces/c/3/sources
PKG_HASH:=6daca3b23364d8d883dc77a73f681242f69389e3564543287ed3d073007e0a8e

PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/package.mk

define Package/libxerces-c/Default
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Validating XML parser library for C++
  URL:=https://xerces.apache.org/
endef

define Package/libxerces-c
$(call Package/libxerces-c/Default)
  DEPENDS:=$(ICONV_DEPENDS) +libstdcpp
endef

define Package/libxerces-c-samples
$(call Package/libxerces-c/Default)
  TITLE+= (samples)
  DEPENDS+=+libxerces-c
endef

define Package/libxerces-c/description
  Xerces-C++ is a validating XML parser written in a portable subset of
  C++. Xerces-C++ makes it easy to give your application the ability
  to read and write XML data. A shared library is provided for parsing,
  generating, manipulating, and validating XML documents. Xerces-C++ is
  faithful to the XML 1.0 recommendation and associated standards (DOM
  1.0, DOM 2.0, SAX 1.0, SAX 2.0, Namespaces, XML Schema Part 1 and
  Part 2). It also provides experimental implementations of XML 1.1
  and DOM Level 3.0. The parser provides high performance, modularity,
  and scalability.
endef

define Package/libxerces-c-samples/description
  Validating XML parser library for C++ (samples)
endef

CONFIGURE_ARGS += \
	--disable-rpath \
	--enable-msgloader-inmemory \
	--enable-netaccessor-socket \
	--enable-transcoder-iconv \
	--with-pic

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/xercesc/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/xercesc/* $(1)/usr/include/xercesc/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/{*.a,*.so} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/xerces-c.pc $(1)/usr/lib/pkgconfig/xerces-c.pc
endef

define Package/libxerces-c/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so $(1)/usr/lib/
endef

define Package/libxerces-c-samples/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libxerces-c))
$(eval $(call BuildPackage,libxerces-c-samples))
