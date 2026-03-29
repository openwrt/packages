#
# Copyright (C) 2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-augeas
PKG_VERSION:=1.2.0
PKG_RELEASE:=1

PYPI_NAME:=python-augeas
PKG_HASH:=d2334710e12bdec8b6633a7c2b72df4ca24ab79094a3c9e699494fdb62054a10

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=python-cffi/host  # cffi>=1.0.0

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-augeas
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python bindings for Augeas
  URL:=http://augeas.net
  DEPENDS:=+python3-light +python3-cffi +augeas
endef

define Package/python3-augeas/description
  Pure python bindings for Augeas.
endef

$(eval $(call Py3Package,python3-augeas))
$(eval $(call BuildPackage,python3-augeas))
$(eval $(call BuildPackage,python3-augeas-src))
