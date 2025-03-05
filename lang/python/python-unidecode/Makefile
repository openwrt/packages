#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-unidecode
PKG_VERSION:=1.3.6
PKG_RELEASE:=1

PYPI_NAME:=Unidecode
PKG_HASH:=fed09cf0be8cf415b391642c2a5addfc72194407caee4f98719e40ec2a72b830

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-unidecode
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=ASCII transliterations of Unicode text
  URL:=https://github.com/avian2/unidecode
  DEPENDS:=+python3-light
endef

define Package/python-unidecode/description
  Unidecode, lossy ASCII transliterations of Unicode text
endef

$(eval $(call Py3Package,python3-unidecode))
$(eval $(call BuildPackage,python3-unidecode))
$(eval $(call BuildPackage,python3-unidecode-src))
