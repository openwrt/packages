# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cryptodomex
PKG_VERSION:=3.9.0
PKG_RELEASE:=1

PYPI_NAME:=pycryptodomex
PKG_HASH:=8b604f4fa1de456d6d19771b01c2823675a75a2c60e51a6b738f71fdfe865370

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.rst
PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>

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

define Package/python-cryptodomex/Default
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A self-contained cryptographic library for Python
  URL:=https://www.pycryptodome.org/
  DEPENDS:=+libgmp
endef

define Package/python-cryptodomex
$(call Package/python-cryptodomex/Default)
  DEPENDS+=+PACKAGE_python-cryptodomex:python
  VARIANT:=python
endef

define Package/python3-cryptodomex
$(call Package/python-cryptodomex/Default)
  DEPENDS+=+PACKAGE_python3-cryptodomex:python3
  VARIANT:=python3
endef

define Package/python-cryptodomex/description
PyCryptodome is a self-contained Python package of low-level
cryptographic primitives.
endef

define Package/python3-cryptodomex/description
$(call Package/python-cryptodomex/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-cryptodomex))
$(eval $(call BuildPackage,python-cryptodomex))
$(eval $(call BuildPackage,python-cryptodomex-src))

$(eval $(call Py3Package,python3-cryptodomex))
$(eval $(call BuildPackage,python3-cryptodomex))
$(eval $(call BuildPackage,python3-cryptodomex-src))
