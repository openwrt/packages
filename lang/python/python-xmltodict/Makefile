#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-xmltodict
PKG_VERSION:=1.0.4
PKG_RELEASE:=1

PYPI_NAME:=xmltodict
PKG_HASH:=6d94c9f834dd9e44514162799d344d815a3a4faec913717a9ecbfa5be1bb8e61

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-xmltodict
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Work with XML like JSON
  URL:=https://github.com/martinblech/xmltodict
  DEPENDS:=+python3-light +python3-xml
endef

define Package/python3-xmltodict/description
xmltodict is a Python module that makes working with XML feel like you
are working with JSON.
endef

$(eval $(call Py3Package,python3-xmltodict))
$(eval $(call BuildPackage,python3-xmltodict))
$(eval $(call BuildPackage,python3-xmltodict-src))
