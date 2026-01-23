#
# Copyright (C) 2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-greenlet
PKG_VERSION:=3.2.4
PKG_RELEASE:=1

PYPI_NAME:=greenlet
PKG_HASH:=0dca0d95ff849f9a364385f36ab49f50065d76964944638be9691e1832e9f86d

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
# FIXME: remove when GCC10 is the oldest supported compiler, or the issue goes away
PKG_BUILD_FLAGS:=no-mips16

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
	+libstdcpp \
	@!arc
endef

define Package/python3-greenlet/description
  The greenlet package is a spin-off of Stackless
  a version of CPython that supports micro-threads called tasklets.
endef

# FIXME: remove when GCC10 is the oldest supported compiler, or the issue goes away
# This is required in addition to PKG_BUILD_FLAGS:=no-mips16 because otherwise MIPS16
# flags are inherited from the Python base package (via sysconfig module)
ifdef CONFIG_USE_MIPS16
TARGET_CFLAGS += -mno-mips16 -mno-interlink-mips16
endif

$(eval $(call Py3Package,python3-greenlet))
$(eval $(call BuildPackage,python3-greenlet))
$(eval $(call BuildPackage,python3-greenlet-src))
$(eval $(call HostBuild))
