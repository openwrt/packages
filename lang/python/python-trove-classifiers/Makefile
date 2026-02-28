#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-trove-classifiers
PKG_VERSION:=2025.9.11.17
PKG_RELEASE:=1

PYPI_NAME:=trove-classifiers
PYPI_SOURCE_NAME:=trove_classifiers
PKG_HASH:=931ca9841a5e9c9408bc2ae67b50d28acf85bef56219b56860876dd1f2d024dd

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=

PKG_HOST_ONLY:=1
PKG_BUILD_DEPENDS:=python-calver/host
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-installer/host \
	python-wheel/host \
	python-calver/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-trove-classifiers
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Canonical source for classifiers on PyPI (pypi.org).
  URL:=https://github.com/pypa/trove-classifiers
  DEPENDS:=+python3-light
  BUILDONLY:=1
endef

define Package/python3-trove-classifiers/description
Canonical source for classifiers on PyPI.

Classifiers categorize projects per PEP 301. Use this package to
validate classifiers in packages for PyPI upload or download.
endef

$(eval $(call Py3Package,python3-trove-classifiers))
$(eval $(call BuildPackage,python3-trove-classifiers))
$(eval $(call BuildPackage,python3-trove-classifiers-src))
$(eval $(call HostBuild))
