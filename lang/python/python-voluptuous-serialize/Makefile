#
# Copyright (C) 2019-2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=voluptuous-serialize
PKG_VERSION:=2.3.0
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=740cd00ce2ecf0f3345d550163fdd2f20de2e0a60c3c678450e68314c2f592f5

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=COPYING

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-voluptuous-serialize
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python Voluptuous Serialize
  URL:=https://github.com/balloob/voluptuous-serialize
  DEPENDS:= \
	+python3-light \
	+python3-voluptuous
  VARIANT:=python3
endef

define Package/python3-voluptuous-serialize/description
  Convert Voluptuous schemas to dictionaries so they can be serialized.
endef

$(eval $(call Py3Package,python3-voluptuous-serialize))
$(eval $(call BuildPackage,python3-voluptuous-serialize))
$(eval $(call BuildPackage,python3-voluptuous-serialize-src))
