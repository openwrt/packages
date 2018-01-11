# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-gnupg
PKG_VERSION:=0.4.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/fc/f1/df6c06da34939f67ea622e0b31dbc5bdb5121b271ab530d151df59974425/
PKG_HASH:=ef47b02eaf41dee3cf4b02ddf83130827318de9fe3eae89d01a3f05859e20e1a

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

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
