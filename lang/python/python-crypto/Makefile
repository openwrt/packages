#
# Copyright (C) 2009-2015, 2017-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-crypto
PKG_VERSION:=2.6.1
PKG_RELEASE:=4

PYPI_NAME:=pycrypto
PKG_HASH:=f2ce1e989b272cfcb677616763e0a2e7ec659effa67a88aa92b3a65528f60a3c

PKG_LICENSE:=Public Domain
PKG_LICENSE_FILES:=COPYRIGHT
PKG_CPE_ID:=cpe:/a:dlitz:pycrypto
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PYTHON_PKG_SETUP_ARGS:=
PYTHON_PKG_SETUP_VARS:= \
  CONFIG_BIG_ENDIAN="$(CONFIG_BIG_ENDIAN)"

PYTHON3_PKG_SETUP_ARGS:=
PYTHON3_PKG_SETUP_VARS:= \
  CONFIG_BIG_ENDIAN="$(CONFIG_BIG_ENDIAN)"

define Package/python-crypto/Default
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python Cryptography Toolkit
  URL:=https://www.dlitz.net/software/pycrypto/
  DEPENDS:=+libgmp
endef

define Package/python-crypto
$(call Package/python-crypto/Default)
  DEPENDS+=+PACKAGE_python-crypto:python
  VARIANT:=python
endef

define Package/python3-crypto
$(call Package/python-crypto/Default)
  DEPENDS+=+PACKAGE_python3-crypto:python3
  VARIANT:=python3
endef

define Package/python-crypto/description
A collection of both secure hash functions (such as MD5 and SHA),
and various encryption algorithms (AES, DES, IDEA, RSA, ElGamal, etc.).
endef

define Package/python3-crypto/description
$(call Package/python-crypto/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-crypto))
$(eval $(call BuildPackage,python-crypto))
$(eval $(call BuildPackage,python-crypto-src))

$(eval $(call Py3Package,python3-crypto))
$(eval $(call BuildPackage,python3-crypto))
$(eval $(call BuildPackage,python3-crypto-src))
