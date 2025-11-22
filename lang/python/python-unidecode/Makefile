#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-unidecode
PKG_VERSION:=1.4.0
PKG_RELEASE:=1

PYPI_NAME:=Unidecode
PKG_HASH:=ce35985008338b676573023acc382d62c264f307c8f7963733405add37ea2b23

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
