#
# Copyright (C) 2022 Julien Malik <julien.malik@paraiso.me>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyfuse3
PKG_VERSION:=3.4.1
PKG_RELEASE:=1

PYPI_NAME:=pyfuse3
PKG_HASH:=602f9c5f944bcdbd5e7f526c0e7f44af41970abedabc72d94ac16563e1b49209

PKG_LICENSE:=LGPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Julien Malik <julien.malik@paraiso.me>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pyfuse3
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=libfuse 3 bindings with async I/O support
  URL:=https://github.com/libfuse/pyfuse3
  DEPENDS:= \
    +python3-light \
    +python3-asyncio \
    +python3-logging \
    +python3-trio \
    +libfuse3
endef

define Package/python3-pyfuse3/description
  pyfuse3 is a set of Python 3 bindings for libfuse 3.

  It provides an asynchronous API compatible with Trio and asyncio,
  and enables you to easily write a full-featured Linux filesystem in Python.
endef

$(eval $(call Py3Package,python3-pyfuse3))
$(eval $(call BuildPackage,python3-pyfuse3))
$(eval $(call BuildPackage,python3-pyfuse3-src))
