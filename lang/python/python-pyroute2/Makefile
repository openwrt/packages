#
# Copyright (C) 2019-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyroute2
PKG_VERSION:=0.9.5
PKG_RELEASE:=1

PYPI_NAME:=pyroute2
PKG_HASH:=a198ccbe545b031b00b10da4b44df33d548db04af944be8107c05a215ba03872

PKG_MAINTAINER:=Martin Matějek <martin.matejek@nic.cz>
PKG_LICENSE:=GPL-2.0-or-later Apache-2.0
PKG_LICENSE_FILES:=LICENSE.GPL-2.0-or-later LICENSE.Apache-2.0

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pyroute2
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python netlink library
  URL:=https://github.com/svinota/pyroute2
  DEPENDS:=+python3
endef

define Package/python3-pyroute2/description
  Pyroute2 is a pure Python netlink library.
  The library was started as an RTNL protocol implementation,
  but now it supports many netlink protocols.
endef

$(eval $(call Py3Package,python3-pyroute2))
$(eval $(call BuildPackage,python3-pyroute2))
$(eval $(call BuildPackage,python3-pyroute2-src))
