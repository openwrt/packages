# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyodbc
PKG_VERSION:=5.3.0
PKG_RELEASE:=1

PYPI_NAME:=pyodbc
PKG_HASH:=2fe0e063d8fb66efd0ac6dc39236c4de1a45f17c33eaded0d553d21c199f4d05

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

# for odbc_config
PKG_BUILD_DEPENDS:= \
	python-setuptools/host \
	unixodbc/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pyodbc
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=DB API module for ODBC
  URL:=https://github.com/mkleehammer/pyodbc
  DEPENDS:=+python3-light +python3-decimal +python3-uuid +libodbc +libstdcpp
endef

define Package/python3-pyodbc/description
pyodbc is an open source Python module that makes accessing ODBC
databases simple. It implements the DB API 2.0 specification but is
packed with even more Pythonic convenience.
endef

$(eval $(call Py3Package,python3-pyodbc))
$(eval $(call BuildPackage,python3-pyodbc))
# no src package - the module does not contain any Python code
