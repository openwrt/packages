#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pycparser
PKG_VERSION:=3.0
PKG_RELEASE:=1

PYPI_NAME:=pycparser
PKG_HASH:=600f49d217304a5902ac3c37e1281c9fe94e4d0489de643a9504c5cdfdfc6b29

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DEPENDS:= \
	python3/host \
	python-setuptools/host
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-setuptools/host \
	python-build/host \
	python-installer/host \
	python-wheel/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-pycparser
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=C parser in Python
  URL:=https://github.com/eliben/pycparser
  DEPENDS:= \
      +python3-light
endef

define Package/python3-pycparser/description
pycparser is a parser for the C language, written in pure Python. It is a
module designed to be easily integrated into applications that need to parse
C source code.
endef

$(eval $(call Py3Package,python3-pycparser))
$(eval $(call BuildPackage,python3-pycparser))
$(eval $(call BuildPackage,python3-pycparser-src))
$(eval $(call HostBuild))
