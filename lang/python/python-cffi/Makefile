#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cffi
PKG_VERSION:=1.10.0
PKG_RELEASE:=1

PKG_SOURCE:=cffi-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/5b/b9/790f8eafcdab455bcd3bd908161f802c9ce5adbf702a83aa7712fcc345b7
PKG_HASH:=b3b02911eb1f6ada203b0763ba924234629b51586f72a21faacc638269f4ced5

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-cffi-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>

HOST_PYTHON_PACKAGE_BUILD_DEPENDS:="cffi==$(PKG_VERSION)"
HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:="cffi==$(PKG_VERSION)"

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)
$(call include_mk, python3-package.mk)

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-cffi/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://cffi.readthedocs.org/
  DEPENDS:=+libffi
endef

define Package/python-cffi
$(call Package/python-cffi/Default)
  TITLE:=python-cffi
  DEPENDS+=+PACKAGE_python-cffi:python-light +PACKAGE_python-cffi:python-pycparser
  VARIANT:=python
endef

define Package/python3-cffi
$(call Package/python-cffi/Default)
  TITLE:=python3-cffi
  DEPENDS+=+PACKAGE_python3-cffi:python3-light +PACKAGE_python3-cffi:python3-pycparser
  VARIANT:=python3
endef

define Package/python-cffi/description
Foreign Function Interface for Python calling C code.
endef

define Package/python3-cffi/description
$(call Package/python-cffi/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-cffi))
$(eval $(call BuildPackage,python-cffi))

$(eval $(call Py3Package,python3-cffi))
$(eval $(call BuildPackage,python3-cffi))
