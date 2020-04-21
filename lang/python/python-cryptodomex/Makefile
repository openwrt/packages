# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cryptodomex
PKG_VERSION:=3.9.7
PKG_RELEASE:=2

PYPI_NAME:=pycryptodomex
PKG_HASH:=50163324834edd0c9ce3e4512ded3e221c969086e10fdd5d3fdcaadac5e24a78

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.rst
PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

PYTHON3_PKG_SETUP_ARGS:=
PYTHON3_PKG_SETUP_VARS:= \
  CONFIG_BIG_ENDIAN="$(CONFIG_BIG_ENDIAN)"

define Package/python3-cryptodomex
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A self-contained cryptographic library for Python
  URL:=https://www.pycryptodome.org/
  DEPENDS:=+libgmp +python3
endef

define Package/python3-cryptodomex/description
PyCryptodome is a self-contained Python package of low-level
cryptographic primitives.
endef

$(eval $(call Py3Package,python3-cryptodomex))
$(eval $(call BuildPackage,python3-cryptodomex))
$(eval $(call BuildPackage,python3-cryptodomex-src))
