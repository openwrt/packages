#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=voluptuous-serialize
PKG_VERSION:=2.1.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/v/voluptuous-serialize/
PKG_HASH:=d30fef4f1aba251414ec0b315df81a06da7bf35201dcfb1f6db5253d738a154f

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=COPYING

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
