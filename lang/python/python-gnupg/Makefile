# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-gnupg
PKG_VERSION:=0.4.4
PKG_RELEASE:=2

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=45daf020b370bda13a1429c859fcdff0b766c0576844211446f9266cae97fb0e

PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_CPE_ID:=cpe:/a:python-gnupg_project:python-gnupg

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-gnupg/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://gnupg.readthedocs.io/en/latest/
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

define PyBuild/Compile
	$(call Build/Compile/PyMod,,\
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)" \
	)
endef

define Py3Build/Compile
	$(call Build/Compile/Py3Mod,,\
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)" \
	)
endef


$(eval $(call PyPackage,python-gnupg))
$(eval $(call BuildPackage,python-gnupg))

$(eval $(call Py3Package,python3-gnupg))
$(eval $(call BuildPackage,python3-gnupg))
