#
# Copyright (C) 2018-2022 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-websockets
PKG_VERSION:=10.3
PKG_RELEASE:=$(AUTORELEASE)

PYPI_NAME:=websockets
PKG_HASH:=fc06cc8073c8e87072138ba1e431300e2d408f054b27047d047b549455066ff4

PKG_MAINTAINER:=Michal Vasilek <michal.vasilek@nic.cz>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-websockets
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Library for developing WebSocket servers and clients
  URL:=https://websockets.readthedocs.io/
  DEPENDS:=+python3-light +python3-asyncio +python3-ctypes +python3-email \
    +python3-logging +python3-urllib
endef

define Package/python3-websockets/description
  websockets is a library for building WebSocket servers and clients
  in Python with a focus on correctness and simplicity.

  Built on top of asyncio, Python’s standard asynchronous I/O framework.
  It provides an elegant coroutine-based API.
endef

$(eval $(call Py3Package,python3-websockets))
$(eval $(call BuildPackage,python3-websockets))
$(eval $(call BuildPackage,python3-websockets-src))
