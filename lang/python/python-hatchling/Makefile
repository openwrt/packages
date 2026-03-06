#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-hatchling
PKG_VERSION:=1.27.0
PKG_RELEASE:=1

PYPI_NAME:=hatchling
PKG_HASH:=971c296d9819abb3811112fc52c7a9751c8d381898f36533bb16f9791e941fd6

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-setuptools/host \
	python-installer/host \
	python-editables/host \
	python-packaging/host \
	python-pathspec/host \
	python-pluggy/host \
	python-trove-classifiers/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-hatchling
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Modern, extensible Python build backend
  URL:=https://hatch.pypa.io/latest/
  DEPENDS:= \
      +python3-light \
      +python3-email \
      +python3-editables \
      +python3-packaging \
      +python3-pathspec \
      +python3-pluggy \
      +python3-trove-classifiers
  BUILDONLY:=1
endef

define Package/python3-hatchling/description
This is the extensible, standards compliant build backend used by Hatch.
endef

$(eval $(call Py3Package,python3-hatchling))
$(eval $(call BuildPackage,python3-hatchling))
$(eval $(call BuildPackage,python3-hatchling-src))
$(eval $(call HostBuild))
