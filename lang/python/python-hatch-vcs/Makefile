#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-hatch-vcs
PKG_VERSION:=0.5.0
PKG_RELEASE:=1

PYPI_NAME:=hatch-vcs
PYPI_SOURCE_NAME:=hatch_vcs
PKG_HASH:=0395fa126940340215090c344a2bf4e2a77bcbe7daab16f41b37b98c95809ff9

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-setuptools/host \
	python-build/host \
	python-installer/host \
	python-hatchling/host \
	python-setuptools-scm/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-hatch-vcs
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Hatch plugin for versioning with your preferred VCS
  URL:=https://github.com/ofek/hatch-vcs
  DEPENDS:=+python3-light +python3-hatchling +python3-setuptools-scm
  BUILDONLY:=1
endef

define Package/python3-hatch-vcs/description
This provides a plugin for Hatch that uses your preferred version
control system (like Git) to determine project versions.
endef

$(eval $(call Py3Package,python3-hatch-vcs))
$(eval $(call BuildPackage,python3-hatch-vcs))
$(eval $(call BuildPackage,python3-hatch-vcs-src))
$(eval $(call HostBuild))
