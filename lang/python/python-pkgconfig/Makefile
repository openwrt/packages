#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pkgconfig
PKG_VERSION:=1.6.0
PKG_RELEASE:=1

PYPI_NAME:=pkgconfig
PKG_HASH:=4a5a6631ce937fafac457104a40d558785a658bbdca5c49b6295bc3fd651907f

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:=python3/host python-build/host python-installer/host python-poetry-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-pkgconfig
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Interface Python with pkg-config
  URL:=https://github.com/matze/pkgconfig
  DEPENDS:=+python3-light
  BUILDONLY:=1
endef

define Package/python3-pkgconfig/description
pkgconfig is a Python module to interface with the pkg-config command
line tool for Python 3.3+.
endef

$(eval $(call Py3Package,python3-pkgconfig))
$(eval $(call BuildPackage,python3-pkgconfig))
$(eval $(call BuildPackage,python3-pkgconfig-src))
$(eval $(call HostBuild))
