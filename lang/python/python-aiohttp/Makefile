#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=aiohttp
PKG_VERSION:=3.5.4
PKG_RELEASE:=1

PKG_SOURCE:=aiohttp-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/a/aiohttp/
PKG_HASH:=9c4c83f4fa1938377da32bc2d59379025ceeee8e24b89f72fcbccd8ca22dc9bf

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:aio-libs_project:aiohttp

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-aiohttp
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Async http client/server framework (asyncio)
  URL:=https://github.com/aio-libs/aiohttp
  DEPENDS:= \
	+python3-light \
	+python3-attrs \
	+python3-chardet \
	+python3-multidict \
	+python3-async-timeout \
	+python3-yarl \
	+python3-logging \
	+python3-codecs \
	+python3-cgi \
	+python3-openssl
  VARIANT:=python3
endef

define Package/python3-aiohttp/description
Asynchronous HTTP client/server framework for asyncio and Python3
endef

$(eval $(call Py3Package,python3-aiohttp))
$(eval $(call BuildPackage,python3-aiohttp))
$(eval $(call BuildPackage,python3-aiohttp-src))
