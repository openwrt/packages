#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libsearpc
PKG_VERSION:=3.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/haiwen/libsearpc/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=c479d85e405674c3450eac040abe143af5a9fafe7f1b74926e2a05280ab5420e

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>, Jeffery To <jeffery.to@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.txt

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../../lang/python/python-package.mk
include ../../lang/python/python3-package.mk

define Package/libsearpc
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Seafile RPC Library
  URL:=https://seafile.com
  DEPENDS:=+glib2 +jansson $(ICONV_DEPENDS)
endef

define Package/libsearpc/description
  Searpc is a simple C language RPC framework based on GObject system.
  Searpc handles the serialization/deserialization part of RPC, the
  transport part is left to users.
endef

define Package/python3-searpc
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python bindings for Searpc
  DEPENDS:=+libsearpc +python3-light +python3-logging
  VARIANT:=python3
endef

define Package/python3-searpc/description
$(call Package/libsearpc/description)

  This package contains the Python bindings for Searpc.
endef

CONFIGURE_ARGS += \
	--disable-compile-demo \
	--disable-server-pkg

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{bin,include}
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsearpc.so* $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libsearpc.pc $(1)/usr/lib/pkgconfig/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/searpc-codegen.py $(1)/usr/bin/
endef

# Include Python 2 bindings in this package to maintain compatibility with previous versions
define Package/libsearpc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)/pysearpc
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsearpc.so* $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/pysearpc/*.py $(1)$(PYTHON_PKG_DIR)/pysearpc/
	rm -f $(1)$(PYTHON_PKG_DIR)/pysearpc/{pygencode,test_pysearpc}.py
endef

define Py3Build/Compile
	rm -rf $(PKG_INSTALL_DIR)$(PYTHON3_PKG_DIR)/pysearpc
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)$(PYTHON3_PKG_DIR)/pysearpc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/pysearpc/*.py $(PKG_INSTALL_DIR)$(PYTHON3_PKG_DIR)/pysearpc/
	rm -f $(PKG_INSTALL_DIR)$(PYTHON3_PKG_DIR)/pysearpc/{pygencode,test_pysearpc}.py
endef

Py3Package/python3-searpc/install:=:

$(eval $(call BuildPackage,libsearpc))

$(eval $(call Py3Package,python3-searpc))
$(eval $(call BuildPackage,python3-searpc))
$(eval $(call BuildPackage,python3-searpc-src))
