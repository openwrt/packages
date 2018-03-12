# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pyodbc
PKG_VERSION:=4.0.21
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/0f/04/c5638a4636fb8117fdc45685f489864459d193b1d892b61dce785ddf58f9
PKG_HASH:=9655f84ca9e5cb2dfffff705601017420c840d55271ba62dd44f05383eff0329
PKG_BUILD_DEPENDS:=python python3 unixodbc
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-pyodbc/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/mkleehammer/pyodbc
  DEPENDS:=+unixodbc +libstdcpp
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
