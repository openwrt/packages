#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libsearpc
PKG_VERSION:=3.1.0
PKG_RELEASE=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/haiwen/libsearpc/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=cbd86d3c37b54ca2060ca537a07940fe3e98498abf345b2f3e1cec488230231a
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE.txt

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../../lang/python/python-package.mk

define Package/libsearpc
    SECTION:=libs
    CATEGORY:=Libraries
    TITLE:=Seafile RPC Library
    URL:=https://seafile.com
    DEPENDS:=+glib2 +jansson +python $(ICONV_DEPENDS)
endef

define Package/libsearpc/description
    Searpc is a simple C language RPC framework based on GObject system.
    Searpc handles the serialization/deserialization part of RPC,
    the transport part is left to users.
endef

CONFIGURE_ARGS += --enable-compile-demo=no \
		    --disable-server-pkg

TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib -liconv

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{bin,include}
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsearpc.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/searpc* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libsearpc.pc $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/searpc-codegen.py $(1)/usr/bin/
endef

define Package/libsearpc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsearpc.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/pysearpc $(1)$(PYTHON_PKG_DIR)
	find $(1) -name "*\.pyc" -o -name "*\.pyo" | xargs rm -f
endef

$(eval $(call BuildPackage,libsearpc))
