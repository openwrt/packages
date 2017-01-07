#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cryptography
PKG_VERSION:=1.5.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/21/e1/37fc14f9d77924e84ba0dcb88eb8352db914583af229287c6c965d66ba0d
PKG_MD5SUM:=66a3e01f5f436d2413ef47b7e6bb7729

PKG_BUILD_DEPENDS:=python-cffi/host

PKG_LICENSE:=Apache-2.0 BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.APACHE LICENSE.BSD
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-cryptography
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-cryptography
	URL:=https://github.com/pyca/cryptography
	DEPENDS:=+libopenssl +python +python-cffi +python-enum34 +python-idna +python-ipaddress +python-pyasn1 +python-six +python-setuptools
endef

define Package/python-cryptography/description
cryptography is a package which provides cryptographic recipes and
primitives to Python developers.  Our goal is for it to be your "cryptographic
standard library". It supports Python 2.6-2.7, Python 3.3+, and PyPy 2.6+.
endef

define PyPackage/python-cryptography/filespec
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/cryptography/hazmat/backends/commoncrypto
-|$(PYTHON_PKG_DIR)/cryptography/hazmat/bindings/commoncrypto
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix="/usr" --root="$(PKG_INSTALL_DIR)")
endef

$(eval $(call PyPackage,python-cryptography))
$(eval $(call BuildPackage,python-cryptography))
