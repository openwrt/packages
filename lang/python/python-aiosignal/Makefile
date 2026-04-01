#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-aiosignal
PKG_VERSION:=1.4.0
PKG_RELEASE:=1

PYPI_NAME:=aiosignal
PKG_HASH:=f47eecd9468083c2029cc99945502cb7708b082c232f9aca65da147157b251c7

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-aiosignal
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=List of registered asynchronous callbacks
  URL:=https://github.com/aio-libs/aiosignal
  DEPENDS:=+python3-light +python3-frozenlist
endef

define Package/python3-aiosignal/description
A project to manage callbacks in asyncio projects.
endef

$(eval $(call Py3Package,python3-aiosignal))
$(eval $(call BuildPackage,python3-aiosignal))
$(eval $(call BuildPackage,python3-aiosignal-src))
