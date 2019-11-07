# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pyodbc
PKG_VERSION:=4.0.26
PKG_RELEASE:=2

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=e52700b5d24a846483b5ab80acd9153f8e593999c9184ffea11596288fb33de3
PKG_BUILD_DEPENDS:=python python3 unixodbc
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_DEPENDS:=unixodbc/host

include ../pypi.mk
include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-pyodbc/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/mkleehammer/pyodbc
  DEPENDS:=+unixodbc $(CXX_DEPENDS)
endef

define Package/python-pyodbc
$(call Package/python-pyodbc/Default)
  TITLE:=python-pyodbc
  DEPENDS+=+PACKAGE_python-pyodbc:python-light \
           +PACKAGE_python-pyodbc:python-logging \
           +PACKAGE_python-pyodbc:python-openssl
  VARIANT:=python
endef

define Package/python3-pyodbc
$(call Package/python-pyodbc/Default)
  TITLE:=python3-pyodbc
  DEPENDS+=+PACKAGE_python3-pyodbc:python3-light
  VARIANT:=python3
endef

define Package/python-pyodbc/description
DB API Module for ODBC

A Python DB API 2 module for ODBC. This project provides an up-to-date,
convenient interface to ODBC using native data types like datetime and decimal.
endef

define Package/python3-pyodbc/description
$(call Package/python-pyodbc/description)

(Variant for Python3)
endef

$(eval $(call PyPackage,python-pyodbc))
$(eval $(call BuildPackage,python-pyodbc))

$(eval $(call Py3Package,python3-pyodbc))
$(eval $(call BuildPackage,python3-pyodbc))
