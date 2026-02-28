#
# Copyright (C) 2018, 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-constantly
PKG_VERSION:=23.10.4
PKG_RELEASE:=1

PYPI_NAME:=constantly
PKG_HASH:=aa92b70a33e2ac0bb33cd745eb61776594dc48764b06c35e0efd050b7f1c7cbd

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=

PKG_BUILD_DEPENDS:=python-versioneer/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-constantly
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Symbolic constants in Python
  URL:=https://github.com/twisted/constantly
  DEPENDS:=+python3-light
endef

define Package/python3-constantly/description
A library that provides symbolic constant support. It includes
collections and constants with text, numeric, and bit flag values.
Originally twisted.python.constants from the Twisted project.
endef

$(eval $(call Py3Package,python3-constantly))
$(eval $(call BuildPackage,python3-constantly))
$(eval $(call BuildPackage,python3-constantly-src))
