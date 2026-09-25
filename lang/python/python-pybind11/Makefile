#
# Copyright (C) 2025 Alexandru Ardelean <ardeleanalex@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pybind11
PKG_VERSION:=3.1.0
PKG_RELEASE:=1

PYPI_NAME:=pybind11
PKG_HASH:=a1cc06b524ab3edca51f8ad3895f9c4fa20b8b19283173dff4ae781449dc9639

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-installer/host \
	python-setuptools/host \
	python-wheel/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-pybind11
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Seamless operability between C++11 and Python
  URL:=https://github.com/pybind/pybind11
  DEPENDS:=+python3
  BUILDONLY:=1
endef

define Package/python3-pybind11/description
  pybind11 is a lightweight header-only library that exposes C++ types
  in Python and vice versa, mainly to create Python bindings of existing
  C++ code.
endef

$(eval $(call Py3Package,python3-pybind11))
$(eval $(call BuildPackage,python3-pybind11))
$(eval $(call BuildPackage,python3-pybind11-src))
$(eval $(call HostBuild))
