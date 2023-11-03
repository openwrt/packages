#
# Copyright (C) 2019-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-more-itertools
PKG_VERSION:=10.1.0
PKG_RELEASE:=1

PYPI_NAME:=more-itertools
PKG_HASH:=626c369fa0eb37bac0291bce8259b332fd59ac792fa5497b59837309cd5b114a

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-flit-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-more-itertools
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=More routines for operating on iterables, beyond itertools
  URL:=https://github.com/more-itertools/more-itertools
  DEPENDS:=+python3-light
endef

define Package/python3-more-itertools/description
  more-itertools library collects additional building blocks,
  recipes, and routines for working with Python iterables.
endef

$(eval $(call Py3Package,python3-more-itertools))
$(eval $(call BuildPackage,python3-more-itertools))
$(eval $(call BuildPackage,python3-more-itertools-src))
