#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-async-timeout
PKG_VERSION:=4.0.2
PKG_RELEASE:=1

PYPI_NAME:=async-timeout
PKG_HASH:=2163e1640ddb52b7a8c80d0a67a08587e5d245cc9c553a74a847056bc2976b15

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-async-timeout
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Timeout context manager for asyncio programs
  URL:=https://github.com/aio-libs/async-timeout
  DEPENDS:= \
  +python3-light \
  +python3-asyncio
endef

define Package/python3-async-timeout/description
Timeout context manager for asyncio programs
endef

$(eval $(call Py3Package,python3-async-timeout))
$(eval $(call BuildPackage,python3-async-timeout))
$(eval $(call BuildPackage,python3-async-timeout-src))
