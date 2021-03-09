#
# Copyright (C) 2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-unidecode
PKG_VERSION:=1.2.0
PKG_RELEASE:=1

PYPI_NAME:=Unidecode
PKG_HASH:=8d73a97d387a956922344f6b74243c2c6771594659778744b2dbdaad8f6b727d

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-unidecode
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=ASCII transliterations of Unicode text
  URL:=https://github.com/avian2/unidecode
  DEPENDS:=+python3-light
endef

define Package/python3-unidecode/description
  Unidecode, lossy ASCII transliterations of Unicode text.
endef

$(eval $(call Py3Package,python3-unidecode))
$(eval $(call BuildPackage,python3-unidecode))
$(eval $(call BuildPackage,python3-unidecode-src))
