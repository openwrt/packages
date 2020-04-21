# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-gnupg
PKG_VERSION:=0.4.4
PKG_RELEASE:=3

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=45daf020b370bda13a1429c859fcdff0b766c0576844211446f9266cae97fb0e

PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_CPE_ID:=cpe:/a:python-gnupg_project:python-gnupg

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-gnupg
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=python3-gnupg
  URL:=https://gnupg.readthedocs.io/en/latest/
  DEPENDS:=+gnupg +python3-light
endef

define Package/python3-gnupg/description
A Python wrapper for GnuPG

This module allows easy access to GnuPG.s key management, encryption
and signature functionality from Python programs, by interacting with
GnuPG through file descriptors. Input arguments are strictly checked
and sanitised, and therefore this module should be safe to use in
networked applications requiring direct user input. It is intended for
use on Windows, MacOS X, BSD, or Linux, with Python 2.6, Python 2.7,
Python 3.3, Python 3.4, or PyPy.
endef

define Py3Build/Compile
	$(call Python3/ModSetup,,\
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)" \
	)
endef

$(eval $(call Py3Package,python3-gnupg))
$(eval $(call BuildPackage,python3-gnupg))
