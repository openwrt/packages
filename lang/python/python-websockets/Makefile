#
# Copyright (C) 2018-2022 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-websockets
PKG_VERSION:=11.0.3
PKG_RELEASE:=1

PYPI_NAME:=websockets
PKG_HASH:=88fc51d9a26b10fc331be344f1781224a375b78488fc343620184e95a4b27016

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
  TITLE:=Implementation of the WebSocket Protocol
  URL:=https://github.com/aaugustin/websockets
  DEPENDS:=+python3
endef

define Package/python3-websockets/description
websockets is a library for building WebSocket servers and clients in
Python with a focus on correctness, simplicity, robustness, and
performance.

Built on top of asyncio, Python's standard asynchronous I/O framework,
the default implementation provides an elegant coroutine-based API.
endef

$(eval $(call Py3Package,python3-websockets))
$(eval $(call BuildPackage,python3-websockets))
$(eval $(call BuildPackage,python3-websockets-src))
