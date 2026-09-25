#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-async-timeout
PKG_VERSION:=5.0.1
PKG_RELEASE:=1

PYPI_NAME:=async-timeout
PYPI_SOURCE_NAME:=async_timeout
PKG_HASH:=d9321a7a3d5a6a5e187e824d2fa0793ce379a202935782d555d6e9d2735677d3

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
  +python3-asyncio \
  +python3-logging
endef

define Package/python3-async-timeout/description
Timeout context manager for asyncio programs
endef

$(eval $(call Py3Package,python3-async-timeout))
$(eval $(call BuildPackage,python3-async-timeout))
$(eval $(call BuildPackage,python3-async-timeout-src))
