# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cryptodomex
PKG_VERSION:=3.18.0
PKG_RELEASE:=1

PYPI_NAME:=pycryptodomex
PKG_HASH:=3e3ecb5fe979e7c1bb0027e518340acf7ee60415d79295e5251d13c68dde576e

PKG_LICENSE:=Public-Domain BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.rst
PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>
PKG_CPE_ID:=cpe:/a:pycryptodome:pycryptodomex

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

PYTHON3_PKG_BUILD_VARS:= \
  CONFIG_BIG_ENDIAN="$(CONFIG_BIG_ENDIAN)"

define Package/python3-cryptodomex
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Self-contained cryptographic library
  URL:=https://www.pycryptodome.org/
  DEPENDS:=+libgmp +python3-light +python3-cffi
endef

define Package/python3-cryptodomex/description
PyCryptodome is a self-contained Python package of low-level
cryptographic primitives.
endef

$(eval $(call Py3Package,python3-cryptodomex))
$(eval $(call BuildPackage,python3-cryptodomex))
$(eval $(call BuildPackage,python3-cryptodomex-src))
