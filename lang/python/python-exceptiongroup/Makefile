#
# Copyright (C) 2022 Julien Malik <julien.malik@paraiso.me>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-exceptiongroup
PKG_VERSION:=1.0.4
PKG_RELEASE:=1

PYPI_NAME:=exceptiongroup
PKG_HASH:=bd14967b79cd9bdb54d97323216f8fdf533e278df937aa2a90089e7d6e06e5ec

PKG_LICENSE:=MIT,Python-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Julien Malik <julien.malik@paraiso.me>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-exceptiongroup
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Backport of PEP 654 (exception groups)
  URL:=https://github.com/agronholm/exceptiongroup
  DEPENDS:= \
    +python3-light \
    +python3-attrs
endef

define Package/python3-exceptiongroup/description
  This is a backport of the BaseExceptionGroup and ExceptionGroup classes from Python 3.11.
endef

$(eval $(call Py3Package,python3-exceptiongroup))
$(eval $(call BuildPackage,python3-exceptiongroup))
$(eval $(call BuildPackage,python3-exceptiongroup-src))
