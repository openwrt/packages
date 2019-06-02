# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cryptodomex
PKG_VERSION:=3.8.2
PKG_RELEASE:=1

PKG_SOURCE:=pycryptodomex-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pycryptodomex
PKG_HASH:=e50b15af6bbdc6b5f8bd70d818cb846b15303ffa6c371b799db561a403a21607

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-cryptodomex-$(PKG_VERSION)

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
