#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-installer
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PYPI_NAME:=installer
PKG_HASH:=052c7fc3721d54c696e2dea019be67539d7b144e924f559f54beb3121831c364

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:=python3/host python-flit-core/host

PYTHON3_HOST_INSTALL_VARS:=PYTHONPATH=src

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-installer
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A library for installing Python wheels
  URL:=https://github.com/pypa/installer
  DEPENDS:=+python3-light +python3-urllib
  BUILDONLY:=1
endef

define Package/python3-installer/description
This is a low-level library for installing a Python package from a wheel
distribution. It provides basic functionality and abstractions for
handling wheels and installing packages from wheels.
endef

Host/Compile=$(Py3Host/Compile/Bootstrap)

$(eval $(call Py3Package,python3-installer))
$(eval $(call BuildPackage,python3-installer))
$(eval $(call BuildPackage,python3-installer-src))
$(eval $(call HostBuild))
