# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=python-uvicorn
PKG_VERSION:=0.46.0
PKG_RELEASE:=1

PYPI_NAME:=uvicorn
PKG_HASH:=fb9da0926999cc6cb22dc7cd71a94a632f078e6ae47ff683c5c420750fb7413d

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.md

HOST_BUILD_DEPENDS:= \
	python3/host \
	python-click/host \
	python-h11/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-uvicorn
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Uvicorn
  URL:=https://github.com/Kludex/uvicorn
  DEPENDS:= \
    +python3-asyncio \
    +python3-click \
    +python3-h11 \
    +python3-light \
    +python3-logging \
    +python3-multiprocessing \
    +python3-openssl \
    +python3-urllib
endef

define Package/python3-uvicorn/description
  Uvicorn is an ASGI web server implementation for Python.
endef

$(eval $(call Py3Package,python3-uvicorn))
$(eval $(call BuildPackage,python3-uvicorn))
$(eval $(call BuildPackage,python3-uvicorn-src))
$(eval $(call HostBuild))
