#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cryptography
PKG_VERSION:=1.9
PKG_RELEASE:=1

PKG_SOURCE:=cryptography-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/2a/0c/31bd69469e90035381f0197b48bf71032991d9f07a7e444c311b4a23a3df
PKG_HASH:=5518337022718029e367d982642f3e3523541e098ad671672a90b82474c84882

PKG_LICENSE:=Apache-2.0 BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.APACHE LICENSE.BSD
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-cryptography-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)
$(call include_mk, python3-package.mk)

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-cryptography/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/pyca/cryptography
  DEPENDS:=+libopenssl
endef

define Package/python-cryptography
$(call Package/python-cryptography/Default)
  TITLE:=python-cryptography
  DEPENDS+= \
      +PACKAGE_python-cryptography:python \
      +PACKAGE_python-cryptography:python-cffi \
      +PACKAGE_python-cryptography:python-enum34 \
      +PACKAGE_python-cryptography:python-idna \
      +PACKAGE_python-cryptography:python-ipaddress \
      +PACKAGE_python-cryptography:python-pyasn1 \
      +PACKAGE_python-cryptography:python-six
  VARIANT:=python
endef

define Package/python3-cryptography
$(call Package/python-cryptography/Default)
  TITLE:=python3-cryptography
  DEPENDS+= \
      +PACKAGE_python3-cryptography:python3 \
      +PACKAGE_python3-cryptography:python3-cffi \
      +PACKAGE_python3-cryptography:python3-idna \
      +PACKAGE_python3-cryptography:python3-pyasn1 \
      +PACKAGE_python3-cryptography:python3-six
  VARIANT:=python3
endef

define Package/python-cryptography/description
cryptography is a package which provides cryptographic recipes and
primitives to Python developers.  Our goal is for it to be your "cryptographic
standard library". It supports Python 2.6-2.7, Python 3.3+, and PyPy 2.6+.
endef

define Package/python3-cryptography/description
$(call Package/python-cryptography/description)
.
(Variant for Python3)
endef

define PyPackage/python-cryptography/filespec
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/cryptography/hazmat/backends/commoncrypto
-|$(PYTHON_PKG_DIR)/cryptography/hazmat/bindings/commoncrypto
endef

define Py3Package/python3-cryptography/filespec
+|$(PYTHON3_PKG_DIR)
-|$(PYTHON3_PKG_DIR)/cryptography/hazmat/backends/commoncrypto
-|$(PYTHON3_PKG_DIR)/cryptography/hazmat/bindings/commoncrypto
endef

$(eval $(call PyPackage,python-cryptography))
$(eval $(call BuildPackage,python-cryptography))
$(eval $(call Py3Package,python3-cryptography))
$(eval $(call BuildPackage,python3-cryptography))
