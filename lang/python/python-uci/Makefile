#
# Copyright (C) 2018-2022 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-uci
PKG_VERSION:=0.10.3
PKG_RELEASE:=2

PYPI_NAME:=pyuci
PKG_HASH:=3b0f72ea81ed7a7999b2eb73f57a93019c0d359efaa9efb44fdf377fa09c1da6

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-uci
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python UCI bindings
  URL:=https://gitlab.nic.cz/turris/pyuci/
  DEPENDS:=+python3-light +libuci
endef

define Package/python3-uci/description
  Python3 bindings for Unified Configuration Interface.
endef

$(eval $(call Py3Package,python3-uci))
$(eval $(call BuildPackage,python3-uci))
$(eval $(call BuildPackage,python3-uci-src))
