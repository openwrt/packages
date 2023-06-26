#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-hatchling
PKG_VERSION:=1.18.0
PKG_RELEASE:=1

PYPI_NAME:=hatchling
PKG_HASH:=50e99c3110ce0afc3f7bdbadff1c71c17758e476731c27607940cfa6686489ca

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-installer/host \
	python-editables/host \
	python-packaging/host \
	python-pathspec/host \
	python-pluggy/host \
	python-trove-classifiers/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-hatchling
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Modern, extensible Python build backend
  URL:=https://hatch.pypa.io/latest/
  DEPENDS:= \
      +python3-light \
      +python3-email \
      +python3-editables \
      +python3-packaging \
      +python3-pathspec \
      +python3-pluggy \
      +python3-trove-classifiers
  BUILDONLY:=1
endef

define Package/python3-hatchling/description
This is the extensible, standards compliant build backend used by Hatch.
endef

$(eval $(call Py3Package,python3-hatchling))
$(eval $(call BuildPackage,python3-hatchling))
$(eval $(call BuildPackage,python3-hatchling-src))
$(eval $(call HostBuild))
