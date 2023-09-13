#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-semantic-version
PKG_VERSION:=2.10.0
PKG_RELEASE:=1

PYPI_NAME:=semantic-version
PYPI_SOURCE_NAME:=semantic_version
PKG_HASH:=bdabb6d336998cbb378d4b9db3a4b56a1e3235701dc05ea2690d9a997ed5041c

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:=python3/host python-build/host python-installer/host python-wheel/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-semantic-version
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Library implementing the 'SemVer' scheme
  URL:=https://github.com/rbarrois/python-semanticversion
  DEPENDS:=+python3-light
  BUILDONLY:=1
endef

define Package/python3-semantic-version/description
This small python library provides a few tools to handle SemVer in
Python. It follows strictly the 2.0.0 version of the SemVer scheme.
endef

$(eval $(call Py3Package,python3-semantic-version))
$(eval $(call BuildPackage,python3-semantic-version))
$(eval $(call BuildPackage,python3-semantic-version-src))
$(eval $(call HostBuild))
