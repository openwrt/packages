# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cryptodome
PKG_VERSION:=3.9.0
PKG_RELEASE:=1

PYPI_NAME:=pycryptodome
PKG_HASH:=dbeb08ad850056747aa7d5f33273b7ce0b9a77910604a1be7b7a6f2ef076213f

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.rst
PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>
PKG_CPE_ID:=cpe:/a:pycryptodome:pycryptodome

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

define Package/python-cryptodome/Default
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A self-contained cryptographic library for Python
  URL:=https://www.pycryptodome.org/
  DEPENDS:=+libgmp
endef

define Package/python-cryptodome
$(call Package/python-cryptodome/Default)
  DEPENDS+=+PACKAGE_python-cryptodome:python
  VARIANT:=python
  CONFLICTS:=python-crypto
endef

define Package/python3-cryptodome
$(call Package/python-cryptodome/Default)
  DEPENDS+=+PACKAGE_python3-cryptodome:python3
  VARIANT:=python3
  CONFLICTS:=python3-crypto
endef

define Package/python-cryptodome/description
PyCryptodome is a self-contained Python package of low-level
cryptographic primitives.
endef

define Package/python3-cryptodome/description
$(call Package/python-cryptodome/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-cryptodome))
$(eval $(call BuildPackage,python-cryptodome))
$(eval $(call BuildPackage,python-cryptodome-src))

$(eval $(call Py3Package,python3-cryptodome))
$(eval $(call BuildPackage,python3-cryptodome))
$(eval $(call BuildPackage,python3-cryptodome-src))
