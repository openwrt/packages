#
# Copyright (C) 2026 Andreas Hirschauer
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyudev
PKG_VERSION:=0.24.5
PKG_RELEASE:=1

PYPI_NAME:=pyudev
PKG_HASH:=4e7faaec419b81a902d057568101819f448972c0cf448bb9c22203e4fc6a8eb9

PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Andreas Hirschauer <andi@linux.com>
PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pyudev
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python bindings for libudev
  URL:=https://github.com/pyudev/pyudev
  DEPENDS:=+python3-light +python3-ctypes +libudev-zero
endef


define Package/python3-pyudev/description
 pyudev is a pure Python binding for libudev.
endef

$(eval $(call Py3Package,python3-pyudev))
$(eval $(call BuildPackage,python3-pyudev))
$(eval $(call BuildPackage,python3-pyudev-src))
