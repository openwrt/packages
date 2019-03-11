# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cryptodome
PKG_VERSION:=3.7.3
PKG_RELEASE:=1

PKG_SOURCE:=pycryptodome-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pycryptodome
PKG_HASH:=1a222250e43f3c659b4ebd5df3e11c2f112aab6aef58e38af55ef5678b9f0636

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-cryptodome-$(PKG_VERSION)

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.rst
PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

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
