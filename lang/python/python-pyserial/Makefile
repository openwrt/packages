#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyserial
PKG_VERSION:=3.5
PKG_RELEASE:=1

PYPI_NAME:=pyserial
PKG_HASH:=3c77e014170dfffbd816e6ffc205e9842efb10be9f58ec16d3e8675b4925cddb

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Micke Prag <micke.prag@telldus.se>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pyserial
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Serial Port Extension
  URL:=https://github.com/pyserial/pyserial
  DEPENDS:=+python3-light +python3-logging +python3-urllib
endef

define Package/python3-pyserial/description
This module encapsulates the access for the serial port. It provides
backends for Python running on Windows, OSX, Linux, BSD (possibly any
POSIX compliant system) and IronPython. The module named "serial"
automatically selects the appropriate backend.
endef

$(eval $(call Py3Package,python3-pyserial))
$(eval $(call BuildPackage,python3-pyserial))
$(eval $(call BuildPackage,python3-pyserial-src))
