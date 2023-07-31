#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pathspec
PKG_VERSION:=0.11.2
PKG_RELEASE:=1

PYPI_NAME:=pathspec
PKG_HASH:=e0d8d0ac2f12da61956eb2306b69f9469b42f4deb0f3cb6ed47b9cce9996ced3

PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:=python3/host python-build/host python-installer/host python-flit-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-pathspec
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=gitignore style pattern matching of file paths
  URL:=https://github.com/cpburnz/python-pathspec
  DEPENDS:=+python3-light
  BUILDONLY:=1
endef

define Package/python3-pathspec/description
pathspec is a utility library for pattern matching of file paths. So far
this only includes Git's wildmatch pattern matching which itself is
derived from Rsync's wildmatch. Git uses wildmatch for its gitignore
files.
endef

$(eval $(call Py3Package,python3-pathspec))
$(eval $(call BuildPackage,python3-pathspec))
$(eval $(call BuildPackage,python3-pathspec-src))
$(eval $(call HostBuild))
