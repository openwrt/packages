#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-setuptools
PKG_VERSION:=82.0.1
PKG_RELEASE:=2

PYPI_NAME:=setuptools
PKG_HASH:=7d872682c5d01cfde07da7bccc7b65469d3dca203318515ada1de5eda35efbf9

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_CPE_ID:=cpe:/a:python:setuptools

HOST_BUILD_DEPENDS:= \
        python3/host \
        python-wheel/host \
        python-packaging/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-setuptools/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/pypa/setuptools
endef

define Package/python3-setuptools
$(call Package/python3-setuptools/Default)
  TITLE:=Fully-featured library to package Python projects
  DEPENDS:=+python3
endef

define Package/python3-setuptools/description
Setuptools is a fully-featured, actively-maintained, and stable library
designed to facilitate packaging Python projects.

It helps developers to easily share reusable code (in the form of a
library) and programs (e.g., CLI/GUI tools implemented in Python), that
can be installed with pip and uploaded to PyPI.
endef

$(eval $(call Py3Package,python3-setuptools))

$(eval $(call BuildPackage,python3-setuptools))

$(eval $(call BuildPackage,python3-setuptools-src))

$(eval $(call HostBuild))
