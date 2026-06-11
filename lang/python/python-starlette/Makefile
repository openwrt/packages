# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=python-starlette
PKG_VERSION:=1.2.1
PKG_RELEASE:=1

PYPI_NAME:=starlette
PKG_HASH:=9b9b5ebb992e67d6093741e63c2f59e4f6fff986f81163c087867bd7b924b3f6

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.md

HOST_BUILD_DEPENDS:= \
	python-anyio/host \
	python-setuptools/host
PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-starlette
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Starlette
  URL:=https://github.com/agronholm/starlette
  DEPENDS:= \
    +python3-asyncio \
    +python3-anyio \
    +python3-light \
    +python3-urllib \
    +python3-uuid
endef

define Package/python3-starlette/description
  Starlette is a lightweight ASGI framework/toolkit, which is ideal for
  building async web services in Python.
endef

$(eval $(call Py3Package,python3-starlette))
$(eval $(call BuildPackage,python3-starlette))
$(eval $(call BuildPackage,python3-starlette-src))
$(eval $(call HostBuild))
