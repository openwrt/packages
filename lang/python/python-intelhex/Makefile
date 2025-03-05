# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-intelhex
PKG_VERSION:=2.3.0
PKG_RELEASE:=1

PYPI_NAME:=intelhex
PKG_HASH:=892b7361a719f4945237da8ccf754e9513db32f5628852785aea108dcd250093

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com> 
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.txt

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-intelhex
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Intel HEX files manipulations
  URL:=https://github.com/python-intelhex/intelhex
  DEPENDS:=+python3-light
endef

define Package/python3-intelhex/description
  This work implements an intelhex Python library to read, write, create from
  scratch and manipulate data from Intel HEX file format.
endef

$(eval $(call Py3Package,python3-intelhex))
$(eval $(call BuildPackage,python3-intelhex))
$(eval $(call BuildPackage,python3-intelhex-src))
