#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-more-itertools
PKG_VERSION:=7.1.0
PKG_RELEASE:=1

PKG_SOURCE:=more-itertools-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/m/more-itertools
PKG_HASH:=8bb43d1f51ecef60d81854af61a3a880555a14643691cc4b64a6ee269c78f09a
PKG_BUILD_DIR:=$(BUILD_DIR)/more-itertools-$(PKG_VERSION)

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-more-itertools
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=More routines for operating on iterables, beyond itertools
  URL:=https://github.com/erikrose/more-itertools
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python3-more-itertools/description
  more-itertools library collects additional building blocks,
  recipes, and routines for working with Python iterables.
endef


$(eval $(call Py3Package,python3-more-itertools))
$(eval $(call BuildPackage,python3-more-itertools))
$(eval $(call BuildPackage,python3-more-itertools-src))
