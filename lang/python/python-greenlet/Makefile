#
# Copyright (C) 2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-greenlet
PKG_VERSION:=3.3.1
PKG_RELEASE:=1

PYPI_NAME:=greenlet
PKG_HASH:=41848f3230b58c08bb43dee542e74a2a2e34d3c59dc3076cec9151aeeedcae98

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:= \
	python3/host \
	python-setuptools/host \
	python-wheel/host

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

define Package/python3-greenlet
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lightweight coroutines for in-process concurrent programming
  URL:=https://github.com/python-greenlet/greenlet
  DEPENDS:= \
	+python3-light \
	+libstdcpp
endef

define Package/python3-greenlet/description
  The greenlet package is a spin-off of Stackless
  a version of CPython that supports micro-threads called tasklets.
endef

$(eval $(call Py3Package,python3-greenlet))
$(eval $(call BuildPackage,python3-greenlet))
$(eval $(call BuildPackage,python3-greenlet-src))
$(eval $(call HostBuild))
