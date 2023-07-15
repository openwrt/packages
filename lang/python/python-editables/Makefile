#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-editables
PKG_VERSION:=0.4
PKG_RELEASE:=1

PYPI_NAME:=editables
PKG_HASH:=dc322c42e7ccaf19600874035a4573898d88aadd07e177c239298135b75da772

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:=python3/host python-build/host python-installer/host python-flit-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-editables
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Editable installations
  URL:=https://github.com/pfmoore/editables
  DEPENDS:=+python3-light
  BUILDONLY:=1
endef

define Package/python3-editables/description
A Python library for creating "editable wheels"

This library supports the building of wheels which, when installed, will
expose packages in a local directory on sys.path in "editable mode". In
other words, changes to the package source will be reflected in the
package visible to Python, without needing a reinstall.
endef

$(eval $(call Py3Package,python3-editables))
$(eval $(call BuildPackage,python3-editables))
$(eval $(call BuildPackage,python3-editables-src))
$(eval $(call HostBuild))
