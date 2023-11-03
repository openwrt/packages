#
# Copyright (C) 2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-ciso8601
PKG_VERSION:=2.3.0
PKG_RELEASE:=1

PYPI_NAME:=ciso8601
PKG_HASH:=19e3fbd786d8bec3358eac94d8774d365b694b604fd1789244b87083f66c8900

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-ciso8601
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Fast ISO8601 date time parser written in C
  URL:=https://github.com/closeio/ciso8601
  DEPENDS:=+python3-light
endef

define Package/python3-ciso8601/description
ciso8601 converts ISO 8601 or RFC 3339 date time strings into Python
datetime objects.
endef

$(eval $(call Py3Package,python3-ciso8601))
$(eval $(call BuildPackage,python3-ciso8601))
$(eval $(call BuildPackage,python3-ciso8601-src))

