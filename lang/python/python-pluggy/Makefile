#
# Copyright (C) 2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pluggy
PKG_VERSION:=1.7.0
PKG_RELEASE:=1

PYPI_NAME:=pluggy
PKG_HASH:=d1eaa46ebb595891b860ab086b4d09c8588af65ebd4361b8e8f4bb8920b90ba8

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:= \
	python3/host \
	python-setuptools/host \
	python-setuptools-scm/host
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

# Break circular dependency:
#   pluggy/host -> setuptools-scm/host -> vcs-versioning/host -> hatchling/host -> pluggy/host
# Skip the setuptools-scm dependency check and
# set the version statically via setup.cfg fallback.
PYTHON3_HOST_BUILD_ARGS:=--skip-dependency-check

define Host/Compile
	printf '[metadata]\nversion = $(PKG_VERSION)\n' > $(HOST_BUILD_DIR)/setup.cfg
	$(Py3Host/Compile)
endef

define Package/python3-pluggy
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Plugin and hook calling mechanisms for Python
  URL:=https://github.com/pytest-dev/pluggy
  DEPENDS:=+python3-light
endef

define Package/python3-pluggy/description
  A minimalist production ready plugin system for python
endef

$(eval $(call Py3Package,python3-pluggy))
$(eval $(call BuildPackage,python3-pluggy))
$(eval $(call BuildPackage,python3-pluggy-src))
$(eval $(call HostBuild))
