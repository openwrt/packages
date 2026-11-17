#
# Copyright (C) 2018-2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-ubus
PKG_VERSION:=0.1.3
PKG_RELEASE:=1

PYPI_NAME:=ubus
PKG_HASH:=e737ae171b38836c26bc3e50e9c468afd47d9cc8bc01f33a5b569a05e1d8567f

PKG_MAINTAINER:=Erik Larsson <who+openwrt@cnackers.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-setuptools/host

PYTHON3_PKG_FORCE_DISTUTILS_SETUP:=1

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-ubus
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=libubus bindings
  URL:=https://gitlab.nic.cz/turris/python-ubus/
  DEPENDS:=+libubus +libblobmsg-json +python3-light
endef

define Package/python3-ubus/description
  Python bindings for ubus.
endef

$(eval $(call Py3Package,python3-ubus))
$(eval $(call BuildPackage,python3-ubus))
$(eval $(call BuildPackage,python3-ubus-src))
