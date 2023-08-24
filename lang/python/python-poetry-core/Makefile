#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-poetry-core
PKG_VERSION:=1.7.0
PKG_RELEASE:=1

PYPI_NAME:=poetry-core
PYPI_SOURCE_NAME:=poetry_core
PKG_HASH:=8f679b83bd9c820082637beca1204124d5d2a786e4818da47ec8acefd0353b74

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:=python3/host python-build/host python-installer/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-poetry-core
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Poetry PEP 517 Build Backend
  URL:=https://github.com/python-poetry/poetry-core
  DEPENDS:=+python3
  BUILDONLY:=1
endef

define Package/python3-poetry-core/description
A PEP 517 build backend implementation developed for Poetry. This
project is intended to be a light weight, fully compliant,
self-contained package allowing PEP 517 compatible build frontends to
build Poetry managed projects.
endef

$(eval $(call Py3Package,python3-poetry-core))
$(eval $(call BuildPackage,python3-poetry-core))
$(eval $(call BuildPackage,python3-poetry-core-src))
$(eval $(call HostBuild))
