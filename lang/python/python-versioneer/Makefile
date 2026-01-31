#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-versioneer
PKG_VERSION:=0.29
PKG_RELEASE:=1

PYPI_NAME:=versioneer
PKG_HASH:=5ab283b9857211d61b53318b7c792cf68e798e765ee17c27ade9f6c924235731

PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:=python3/host python-build/host python-installer/host python-wheel/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-versioneer
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Easy VCS-based management of project version strings
  URL:=https://github.com/python-versioneer/python-versioneer
  DEPENDS:=+python3-light
  BUILDONLY:=1
endef

define Package/python3-versioneer/description
This is a tool for managing a recorded version number in
setuptools-based python projects. The goal is to remove the tedious and
error-prone "update the embedded version string" step from your release
process. Making a new release should be as easy as recording a new tag
in your version-control system, and maybe making new tarballs.
endef

$(eval $(call Py3Package,python3-versioneer))
$(eval $(call BuildPackage,python3-versioneer))
$(eval $(call BuildPackage,python3-versioneer-src))
$(eval $(call HostBuild))
