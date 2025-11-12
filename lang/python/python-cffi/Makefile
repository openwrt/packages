#
# Copyright (C) 2015-2016, 2018-2021, 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cffi
PKG_VERSION:=2.0.0
PKG_RELEASE:=1

PYPI_NAME:=cffi
PKG_HASH:=44d1b5909021139fe36001ae048dbdde8214afa20200eda0f64c068cac5d5529

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-installer/host \
	python-wheel/host \
	python-pycparser/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-cffi
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=C Foreign Function Interface
  URL:=https://cffi.readthedocs.org/
  DEPENDS:= \
      +libffi \
      +python3-light \
      +python3-ctypes \
      +python3-pycparser
endef

define Package/python3-cffi/description
Foreign Function Interface for Python calling C code.
endef

$(eval $(call Py3Package,python3-cffi))
$(eval $(call BuildPackage,python3-cffi))
$(eval $(call BuildPackage,python3-cffi-src))
$(eval $(call HostBuild))
