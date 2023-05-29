#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-trove-classifiers
PKG_VERSION:=2023.5.24
PKG_RELEASE:=1

PYPI_NAME:=trove-classifiers
PKG_HASH:=fd5a1546283be941f47540a135bdeae8fb261380a6a204d9c18012f2a1b0ceae

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

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
