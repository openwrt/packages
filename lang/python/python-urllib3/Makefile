#
# Copyright (C) 2007-2025 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-urllib3
PKG_VERSION:=2.6.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_CPE_ID:=cpe:/a:python:urllib3

PYPI_NAME:=urllib3
PKG_HASH:=5379eb6e1aba4088bae84f8242960017ec8d8e3decf30480b3a1abdaa9671a3f

PKG_BUILD_DEPENDS:= \
	python-hatch-vcs/host \
	python-hatchling/host \
	python-setuptools-scm/host
HOST_BUILD_DEPENDS:= \
	python-hatch-vcs/host \
	python-hatchling/host \
	python-setuptools-scm/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-urllib3
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Sanity-friendly HTTP client
  URL:=https://urllib3.readthedocs.io/
  DEPENDS:=+python3
endef

define Package/python3-urllib3/description
  HTTP library with thread-safe connection pooling, file post, and more.
endef

$(eval $(call Py3Package,python3-urllib3))
$(eval $(call BuildPackage,python3-urllib3))
$(eval $(call BuildPackage,python3-urllib3-src))
$(eval $(call HostBuild))
