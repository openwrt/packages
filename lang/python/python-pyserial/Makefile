#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyserial
PKG_VERSION:=3.4
PKG_RELEASE:=1

PYPI_NAME:=pyserial
PKG_HASH:=6e2d401fdee0eab996cf734e67773a0143b932772ca8b42451440cfed942c627

PKG_LICENSE:=BSD
PKG_MAINTAINER:=Micke Prag <micke.prag@telldus.se>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-pyserial/Default
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/pyserial/pyserial
endef

define Package/python-pyserial
$(call Package/python-pyserial/Default)
  TITLE:=python-pyserial
  DEPENDS:=+PACKAGE_python-pyserial:python-light
  VARIANT:=python
endef

define Package/python3-pyserial
$(call Package/python-pyserial/Default)
  TITLE:=python3-pyserial
  DEPENDS:=+PACKAGE_python3-pyserial:python3-light
  VARIANT:=python3
endef

define Package/python-pyserial/description
This module encapsulates the access for the serial port. It provides backends
for Python running on Windows, OSX, Linux, BSD (possibly any POSIX compliant
system) and IronPython. The module named "serial" automatically selects the
appropriate backend.
endef

define Package/python3-pyserial/description
$(call Package/python-pyserial/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-pyserial))
$(eval $(call BuildPackage,python-pyserial))
$(eval $(call BuildPackage,python-pyserial-src))

$(eval $(call Py3Package,python3-pyserial))
$(eval $(call BuildPackage,python3-pyserial))
$(eval $(call BuildPackage,python3-pyserial-src))
