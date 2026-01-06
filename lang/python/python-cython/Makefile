#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cython
PKG_VERSION:=3.1.5
PKG_RELEASE:=1

PYPI_NAME:=Cython
PYPI_SOURCE_NAME:=cython
PKG_HASH:=7e73c7e6da755a8dffb9e0e5c4398e364e37671778624188444f1ff0d9458112

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:= \
        python3/host \
        python-build/host \
        python-installer/host \
        python-wheel/host \
        python-setuptools/host \
        python-packaging/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-cython
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Cython compiler for writing C extensions
  URL:=https://cython.org/
  DEPENDS:=+python3
  BUILDONLY:=1
endef

define Package/python3-cython/description
Cython is a language that makes writing C extensions for Python as easy
as Python itself. Cython is based on Pyrex, but supports more cutting
edge functionality and optimizations.

The Cython language is very close to the Python language, but Cython
additionally supports calling C functions and declaring C types on
variables and class attributes. This allows the compiler to generate
very efficient C code from Cython code.

This makes Cython the ideal language for wrapping external C libraries,
and for fast C modules that speed up the execution of Python code.
endef

$(eval $(call Py3Package,python3-cython))
$(eval $(call BuildPackage,python3-cython))
$(eval $(call BuildPackage,python3-cython-src))
$(eval $(call HostBuild))
