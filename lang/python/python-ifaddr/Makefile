#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-ifaddr
PKG_VERSION:=0.1.6
PKG_RELEASE:=1

PYPI_NAME:=ifaddr
PKG_HASH:=c19c64882a7ad51a394451dabcbbed72e98b5625ec1e79789924d5ea3e3ecb93

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
  TITLE:=Enumerate IP addresses on network adapters
  URL:=https://github.com/pydron/ifaddr
  DEPENDS:= \
	+python3-light \
	+python3-ctypes
  VARIANT:=python3
endef

define Package/python3-ifaddr/description
  ifaddr is a small Python library that allows you to find all the IPv4 and IPv6 addresses of the computer.
endef

$(eval $(call Py3Package,python3-ifaddr))
$(eval $(call BuildPackage,python3-ifaddr))
$(eval $(call BuildPackage,python3-ifaddr-src))
