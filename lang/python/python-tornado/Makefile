#
# Copyright (C) 2020 CZ.NIC z.s.p.o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-tornado
PKG_VERSION:=6.3.3
PKG_RELEASE:=1

PYPI_NAME:=tornado
PKG_HASH:=e7d8db41c0181c80d76c982aacc442c0783a2c54d6400fe028954201a2e032fe

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:tornadoweb:tornado

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-tornado
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Web framework and asynchronous networking library
  URL:=https://www.tornadoweb.org
  DEPENDS:=+python3
endef

define Package/python3-tornado/description
  Tornado is a Python web framework and asynchronous networking library,
  originally developed at FriendFeed. By using non-blocking network I/O,
  Tornado can scale to tens of thousands of open connections, making it
  ideal for long polling, WebSockets, and other applications that require
  a long-lived connection to each user.
endef

$(eval $(call Py3Package,python3-tornado))
$(eval $(call BuildPackage,python3-tornado))
$(eval $(call BuildPackage,python3-tornado-src))
