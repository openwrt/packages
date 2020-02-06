#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cryptography
PKG_VERSION:=2.8
PKG_RELEASE:=1

PYPI_NAME:=cryptography
PKG_HASH:=3cda1f0ed8747339bbdf71b9f38ca74c7b592f24f65cdb3ab3765e4b02871651

PKG_LICENSE:=Apache-2.0 BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.APACHE LICENSE.BSD
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DEPENDS:=libffi/host

HOST_PYTHON_PACKAGE_BUILD_DEPENDS:="cffi>=1.8,!=1.11.3"
HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:="cffi>=1.8,!=1.11.3"

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-cryptography/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Cryptographic recipes and primitives
  URL:=https://github.com/pyca/cryptography
  DEPENDS:=+libopenssl
endef

define Package/python-cryptography
$(call Package/python-cryptography/Default)
  DEPENDS+= \
      +PACKAGE_python-cryptography:python \
      +PACKAGE_python-cryptography:python-cffi \
      +PACKAGE_python-cryptography:python-enum34 \
      +PACKAGE_python-cryptography:python-ipaddress \
      +PACKAGE_python-cryptography:python-six
  VARIANT:=python
endef

define Package/python3-cryptography
$(call Package/python-cryptography/Default)
  DEPENDS+= \
      +PACKAGE_python3-cryptography:python3 \
      +PACKAGE_python3-cryptography:python3-cffi \
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

$(eval $(call PyPackage,python-cryptography))
$(eval $(call BuildPackage,python-cryptography))
$(eval $(call BuildPackage,python-cryptography-src))

$(eval $(call Py3Package,python3-cryptography))
$(eval $(call BuildPackage,python3-cryptography))
$(eval $(call BuildPackage,python3-cryptography-src))
