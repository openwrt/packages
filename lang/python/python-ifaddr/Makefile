#
# Copyright (C) 2019-2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-ifaddr
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PYPI_NAME:=ifaddr
PKG_HASH:=cc0cbfcaabf765d44595825fb96a99bb12c79716b73b44330ea38ee2b0c4aed4

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-ifaddr
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Network interface and IP address enumeration library
  URL:=https://github.com/pydron/ifaddr
  DEPENDS:= \
	+python3-light \
	+python3-ctypes
endef

define Package/python3-ifaddr/description
ifaddr is a small Python library that allows you to find all the
Ethernet and IP addresses of the computer.
endef

$(eval $(call Py3Package,python3-ifaddr))
$(eval $(call BuildPackage,python3-ifaddr))
$(eval $(call BuildPackage,python3-ifaddr-src))
