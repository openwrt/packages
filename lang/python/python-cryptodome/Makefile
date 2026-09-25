# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cryptodome
PKG_VERSION:=3.23.0
PKG_RELEASE:=1

PYPI_NAME:=pycryptodome
PKG_HASH:=447700a657182d60338bab09fdb27518f8856aecd80ae4c6bdddb67ff5da44ef

PKG_LICENSE:=Public-Domain BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.rst
PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>
PKG_CPE_ID:=cpe:/a:pycryptodome:pycryptodome

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

PYTHON3_PKG_BUILD_VARS:= \
  CONFIG_BIG_ENDIAN="$(CONFIG_BIG_ENDIAN)"

define Package/python3-cryptodome
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Self-contained cryptographic library
  URL:=https://www.pycryptodome.org/
  DEPENDS:=+libgmp +python3-light +python3-cffi
  PROVIDES:=python3-crypto
endef

define Package/python3-cryptodome/description
PyCryptodome is a self-contained Python package of low-level
cryptographic primitives.
endef

$(eval $(call Py3Package,python3-cryptodome))
$(eval $(call BuildPackage,python3-cryptodome))
$(eval $(call BuildPackage,python3-cryptodome-src))
