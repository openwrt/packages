#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-setuptools-scm
PKG_VERSION:=9.2.2
PKG_RELEASE:=1

PYPI_NAME:=setuptools-scm
PYPI_SOURCE_NAME:=setuptools_scm
PKG_HASH:=1c674ab4665686a0887d7e24c03ab25f24201c213e82ea689d2f3e169ef7ef57

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-setuptools/host \
	python-build/host \
	python-installer/host \
	python-wheel/host \
	python-packaging/host \
	python-typing-extensions/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-setuptools-scm
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=the blessed package to manage your versions by scm tags
  URL:=https://github.com/pypa/setuptools_scm
  DEPENDS:= \
      +python3-light \
      +python3-logging \
      +python3-packaging \
      +python3-setuptools \
      +python3-typing-extensions
  BUILDONLY:=1
endef

define Package/python3-setuptools-scm/description
setuptools_scm extracts Python package versions from git or hg metadata
instead of declaring them as the version argument or in a SCM managed
file.

Additionally setuptools_scm provides setuptools with a list of files
that are managed by the SCM (i.e. it automatically adds all of the
SCM-managed files to the sdist). Unwanted files must be excluded by
discarding them via MANIFEST.in.
endef

$(eval $(call Py3Package,python3-setuptools-scm))
$(eval $(call BuildPackage,python3-setuptools-scm))
$(eval $(call BuildPackage,python3-setuptools-scm-src))
$(eval $(call HostBuild))
