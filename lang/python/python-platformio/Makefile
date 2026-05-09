# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=python-platformio
PKG_VERSION:=6.1.19
PKG_RELEASE:=2

PYPI_NAME:=platformio
PKG_HASH:=7b53eaa36fcba554411b669eab845626da7c4b90fa6aaee9fe9f1875d82f5f54

PKG_MAINTAINER:=Austin Lane <vidplace7@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_DEPENDS:= \
	python-ajsonrpc/host \
	python-bottle/host \
	python-build/host \
	python-click/host \
	python-installer/host \
	python-marshmallow/host \
	python-pyelftools/host \
	python-pyserial/host \
	python-requests/host \
	python-semantic-version/host \
	python-setuptools/host \
	python-starlette/host \
	python-tabulate/host \
	python-uvicorn/host \
	python-wsproto/host
PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-platformio
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=PlatformIO
  URL:=https://github.com/platformio/platformio-core
  DEPENDS:= \
    +python3-ajsonrpc \
    +python3-asyncio \
    +python3-bottle \
    +python3-click \
    +python3-colorama \
    +python3-ctypes \
    +python3-light \
    +python3-logging \
    +python3-marshmallow \
    +python3-multiprocessing \
    +python3-openssl \
    +python3-pyelftools \
    +python3-pyserial \
    +python3-requests \
    +python3-semantic-version \
    +python3-starlette \
    +python3-tabulate \
    +python3-urllib \
    +python3-uuid \
    +python3-uvicorn \
    +python3-wsproto \
    +python3-xml
endef

define Package/python3-platformio/description
  PlatformIO is a cross-platform, cross-architecture, multiple framework,
  professional tool for embedded systems engineers and for software
  developers who write applications for embedded products.
endef

$(eval $(call Py3Package,python3-platformio))
$(eval $(call BuildPackage,python3-platformio))
$(eval $(call BuildPackage,python3-platformio-src))
$(eval $(call HostBuild))
