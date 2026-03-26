#
# Copyright (C) 2025 Alexandru Ardelean <ardeleanalex@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-vcs-versioning
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PYPI_NAME:=vcs-versioning
PYPI_SOURCE_NAME:=vcs_versioning
PKG_HASH:=bd597fd2c79dc4ea0a59fc6a525793acb7d2ba06ee64b80750b97e92b6bcf691

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-hatchling/host \
	python-installer/host \
	python-packaging/host \
	python-typing-extensions/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-vcs-versioning
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=core version inference logic for VCS-based versioning
  URL:=https://github.com/pypa/setuptools-scm
  DEPENDS:= \
      +python3-light \
      +python3-packaging \
      +python3-typing-extensions
  BUILDONLY:=1
endef

define Package/python3-vcs-versioning/description
vcs-versioning provides the core VCS version inference logic used by
setuptools-scm. It enables other build backends to use the same version
inference without a setuptools dependency.
endef

$(eval $(call Py3Package,python3-vcs-versioning))
$(eval $(call BuildPackage,python3-vcs-versioning))
$(eval $(call BuildPackage,python3-vcs-versioning-src))
$(eval $(call HostBuild))
