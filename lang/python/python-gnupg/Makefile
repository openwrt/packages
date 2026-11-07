# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-gnupg
PKG_VERSION:=0.5.7
PKG_RELEASE:=1

PYPI_NAME:=python-gnupg
PYPI_SOURCE_NAME:=python_gnupg
PKG_HASH:=73ea46219f992b361eb1ce54cb0968101670654454916a3ee5df8bb9bf0cc8cc

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_CPE_ID:=cpe:/a:python:python-gnupg

PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-gnupg
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A wrapper for GnuPG
  URL:=https://github.com/vsajip/python-gnupg
  DEPENDS:=+python3-light +python3-logging +python3-urllib
endef

define Package/python3-gnupg/description
  The gnupg module allows Python programs to make use of the
  functionality provided by the GNU Privacy Guard (abbreviated GPG or
  GnuPG). Using this module, Python programs can encrypt and decrypt
  data, digitally sign documents and verify digital signatures, manage
  (generate, list and delete) encryption keys, using Public Key
  Infrastructure (PKI) encryption technology based on OpenPGP.
endef

$(eval $(call Py3Package,python3-gnupg))
$(eval $(call BuildPackage,python3-gnupg))
$(eval $(call BuildPackage,python3-gnupg-src))
