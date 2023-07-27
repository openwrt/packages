#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-dns
PKG_VERSION:=2.4.1
PKG_RELEASE:=1

PYPI_NAME:=dnspython
PKG_HASH:=c33971c79af5be968bb897e95c2448e11a645ee84d93b265ce0b7aabe5dfdca8

PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>

PKG_BUILD_DEPENDS:=python-poetry-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-dns
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=DNS toolkit
  URL:=https://www.dnspython.org/
  DEPENDS:=+python3
endef

define Package/python3-dns/description
dnspython is a DNS toolkit for Python. It supports almost all record
types. It can be used for queries, zone transfers, and dynamic updates.
It supports TSIG authenticated messages and EDNS0.
endef

$(eval $(call Py3Package,python3-dns))
$(eval $(call BuildPackage,python3-dns))
$(eval $(call BuildPackage,python3-dns-src))
