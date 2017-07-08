# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-gnupg
PKG_VERSION:=2.3.0
PKG_RELEASE:=1

PKG_SOURCE_NAME:=gnupg
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/fa/ea/58e0415e1e3c3a0649119158e036ca4a9af154c56ef80f3d6de986bf9cb2/
PKG_MD5SUM:=b6ebde86093f262f8430eff8d8a4c82b
PKG_HASH:=1d90e854dcc7790a7efc3aac5998159553cc34ec599ee2bc7927beb45fb564ec

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_SOURCE_NAME)-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)
$(call include_mk, python3-package.mk)

define Package/python-gnupg/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/isislovecruft/python-gnupg
  DEPENDS:=+gnupg
endef

define Package/python-gnupg
$(call Package/python-gnupg/Default)
  TITLE:=python-pyodbc
  DEPENDS+=+PACKAGE_python-gnupg:python-light
  VARIANT:=python
endef

define Package/python3-gnupg
$(call Package/python-gnupg/Default)
  TITLE:=python3-gnupg
  DEPENDS+=+PACKAGE_python3-gnupg:python3-light
  VARIANT:=python3
endef

define Package/python-gnupg/description
A Python wrapper for GnuPG

This module allows easy access to GnuPG.s key management, encryption
and signature functionality from Python programs, by interacting with
GnuPG through file descriptors. Input arguments are strictly checked
and sanitised, and therefore this module should be safe to use in
networked applications requiring direct user input. It is intended for
use on Windows, MacOS X, BSD, or Linux, with Python 2.6, Python 2.7,
Python 3.3, Python 3.4, or PyPy.
endef

define Package/python3-gnupg/description
$(call Package/python-gnupg/description)

(Variant for Python3)
endef

$(eval $(call PyPackage,python-gnupg))
$(eval $(call BuildPackage,python-gnupg))

$(eval $(call Py3Package,python3-gnupg))
$(eval $(call BuildPackage,python3-gnupg))
