#
# Copyright (C) 2018, 2021, 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-incremental
PKG_VERSION:=22.10.0
PKG_RELEASE:=1

PYPI_NAME:=incremental
PKG_HASH:=912feeb5e0f7e0188e6f42241d2f450002e11bbc0937c65865045854c24c0bd0

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

HOST_BUILD_DEPENDS:=python3/host python-build/host python-installer/host python-wheel/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-incremental
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Versions your Python projects
  URL:=https://github.com/twisted/incremental
  DEPENDS:=+python3-light +python3-distutils +python3-pkg-resources
endef

define Package/python3-incremental/description
Incremental is a small library that versions your Python projects.
endef

$(eval $(call Py3Package,python3-incremental))
$(eval $(call BuildPackage,python3-incremental))
$(eval $(call BuildPackage,python3-incremental-src))
$(eval $(call HostBuild))
