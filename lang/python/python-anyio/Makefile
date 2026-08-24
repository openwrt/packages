# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=python-anyio
PKG_VERSION:=4.14.2
PKG_RELEASE:=1

PYPI_NAME:=anyio
PKG_HASH:=cfa139f3ed1a23ee8f88a145ddb5ac7605b8bbfd8592baacd7ce3d8bb4313c7f

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_DEPENDS:= \
	python-idna/host \
	python-setuptools-scm/host

PKG_BUILD_DEPENDS:=python-setuptools-scm/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-anyio
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Anyio
  URL:=https://github.com/agronholm/anyio
  DEPENDS:= \
    +python3-asyncio \
    +python3-idna \
    +python3-light \
    +python3-logging \
    +python3-openssl \
    +python3-urllib
endef

define Package/python3-anyio/description
  High-level concurrency and networking framework on top of asyncio or
  Trio.
endef

$(eval $(call Py3Package,python3-anyio))
$(eval $(call BuildPackage,python3-anyio))
$(eval $(call BuildPackage,python3-anyio-src))
$(eval $(call HostBuild))
