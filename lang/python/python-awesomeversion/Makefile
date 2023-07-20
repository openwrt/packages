#
# Copyright (C) 2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-awesomeversion
PKG_VERSION:=23.5.0
PKG_RELEASE:=1

PYPI_NAME:=awesomeversion
PKG_HASH:=a505558316010d2d10d487226f79c1157204af00fa462fdcf948e347011dd491

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENCE.md

PKG_BUILD_DEPENDS:=python-poetry-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-awesomeversion
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Make anything a version object
  URL:=https://github.com/ludeeus/awesomeversion
  DEPENDS:=+python3-light
endef

define Package/python3-awesomeversion/description
Make anything a version object, and compare against a vast selection of
other version formats.
endef

$(eval $(call Py3Package,python3-awesomeversion))
$(eval $(call BuildPackage,python3-awesomeversion))
$(eval $(call BuildPackage,python3-awesomeversion-src))
