#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-wheel
PKG_VERSION:=0.47.0
PKG_RELEASE:=1

PYPI_NAME:=wheel
PKG_HASH:=cc72bd1009ba0cf63922e28f94d9d83b920aa2bb28f798a31d0691b02fa3c9b3

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_CPE_ID:=cpe:/a:wheel_project:wheel

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:=python3/host python-build/host python-installer/host python-flit-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-wheel
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A built-package format for Python
  URL:=https://github.com/pypa/wheel
  DEPENDS:=+python3-light +python3-urllib +python3-logging +python3-packaging +python3-setuptools
  BUILDONLY:=1
endef

define Package/python3-wheel/description
This library is the reference implementation of the Python wheel
packaging standard, as defined in PEP 427.
endef

$(eval $(call Py3Package,python3-wheel))
$(eval $(call BuildPackage,python3-wheel))
$(eval $(call BuildPackage,python3-wheel-src))
$(eval $(call HostBuild))
