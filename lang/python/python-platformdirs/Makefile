#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-platformdirs
PKG_VERSION:=4.9.4
PKG_RELEASE:=1

PYPI_NAME:=platformdirs
PKG_HASH:=1ec356301b7dc906d83f371c8f487070e99d3ccf9e501686456394622a01a934

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DEPENDS:=python-hatchling/host python-hatch-vcs/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-platformdirs
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Determine appropriate platform-specific dirs
  URL:=https://github.com/platformdirs/platformdirs
  DEPENDS:=+python3-light +python3-urllib
endef

define Package/python3-platformdirs/description
When writing desktop application, finding the right location to store
user data and configuration varies per platform. Even for
single-platform apps, there may by plenty of nuances in figuring out the
right location.

This kind of thing is what the platformdirs package is for.
endef

$(eval $(call Py3Package,python3-platformdirs))
$(eval $(call BuildPackage,python3-platformdirs))
$(eval $(call BuildPackage,python3-platformdirs-src))
