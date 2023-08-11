#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-multidict
PKG_VERSION:=6.0.4
PKG_RELEASE:=1

PYPI_NAME:=multidict
PKG_HASH:=3666906492efb76453c0e7b97f2cf459b0682e7402c0489a95484965dbc1da49

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-multidict
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=multidict implementation
  URL:=https://github.com/aio-libs/multidict
  DEPENDS:=+python3-light
endef

define Package/python3-multidict/description
Multidict is dict-like collection of key-value pairs where key might be
occurred more than once in the container.
endef

$(eval $(call Py3Package,python3-multidict))
$(eval $(call BuildPackage,python3-multidict))
$(eval $(call BuildPackage,python3-multidict-src))
