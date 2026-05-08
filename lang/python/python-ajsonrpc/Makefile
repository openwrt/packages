# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=python-ajsonrpc
PKG_VERSION:=1.2.0
PKG_RELEASE:=1

PYPI_NAME:=ajsonrpc
PKG_HASH:=791bac18f0bf0dee109194644f151cf8b7ff529c4b8d6239ac48104a3251a19f

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

HOST_BUILD_DEPENDS:=python-setuptools/host
PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-ajsonrpc
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Async JSON-RPC 2.0 protocol + asyncio server
  URL:=https://github.com/pavlov99/ajsonrpc
  DEPENDS:= \
    +python3-asyncio \
    +python3-light \
    +python3-logging
endef

define Package/python3-ajsonrpc/description
  Lightweight JSON-RPC 2.0 protocol implementation and asynchronous server
  powered by asyncio. This library is a successor of json-rpc and written
  by the same team.
endef

$(eval $(call Py3Package,python3-ajsonrpc))
$(eval $(call BuildPackage,python3-ajsonrpc))
$(eval $(call BuildPackage,python3-ajsonrpc-src))
$(eval $(call HostBuild))
