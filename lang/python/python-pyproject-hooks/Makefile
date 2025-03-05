#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyproject-hooks
PKG_VERSION:=1.0.0
PKG_RELEASE:=2

PYPI_NAME:=pyproject_hooks
PKG_HASH:=f271b298b97f5955d53fb12b72c1fb1948c22c1a6b70b315c54cedaca0264ef5

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:=python3/host python-flit-core/host python-installer/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-pyproject-hooks
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Wrappers to call pyproject.toml-based build backend hooks
  URL:=https://github.com/pypa/pyproject-hooks
  DEPENDS:=+python3-light
  BUILDONLY:=1
endef

define Package/python3-pyproject-hooks/description
This is a low-level library for calling build-backends in
pyproject.toml-based project. It provides the basic functionality to
help write tooling that generates distribution files from Python
projects.
endef

Host/Compile=$(Py3Host/Compile/Bootstrap)

$(eval $(call Py3Package,python3-pyproject-hooks))
$(eval $(call BuildPackage,python3-pyproject-hooks))
$(eval $(call BuildPackage,python3-pyproject-hooks-src))
$(eval $(call HostBuild))
