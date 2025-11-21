#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-hatch-requirements-txt
PKG_VERSION:=0.4.1
PKG_RELEASE:=1

PYPI_NAME:=hatch-requirements-txt
PYPI_SOURCE_NAME:=hatch_requirements_txt
PKG_HASH:=2c686e5758fd05bb55fa7d0c198fdd481f8d3aaa3c693260f5c0d74ce3547d20

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-installer/host \
	python-hatchling/host \
	python-packaging/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-hatch-requirements-txt
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Read project dependencies from requirements.txt
  URL:=https://github.com/repo-helper/hatch-requirements-txt
  DEPENDS:=+python3-light +python3-hatchling +python3-packaging
  BUILDONLY:=1
endef

define Package/python3-hatch-requirements-txt/description
Hatchling plugin to read project dependencies from requirements.txt
endef

$(eval $(call Py3Package,python3-hatch-requirements-txt))
$(eval $(call BuildPackage,python3-hatch-requirements-txt))
$(eval $(call BuildPackage,python3-hatch-requirements-txt-src))
$(eval $(call HostBuild))
