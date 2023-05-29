#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=micropython-mpremote
PKG_VERSION:=1.20.0
PKG_RELEASE:=1

PYPI_NAME:=mpremote
PKG_HASH:=5c342762a04791309dd49bce63c70a075aa7c548b1c0076262b96f9ccc398ca2

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_DEPENDS:=python-hatchling/host python-hatch-requirements-txt/host python-hatch-vcs/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/micropython-mpremote
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Interacting remotely with MicroPython devices
  URL:=https://github.com/micropython/micropython
  DEPENDS:=+python3-light +python3-urllib +python3-pyserial
endef

define Package/micropython-mpremote/description
This CLI tool provides an integrated set of utilities to remotely
interact with and automate a MicroPython device over a serial
connection.
endef

$(eval $(call Py3Package,micropython-mpremote))
$(eval $(call BuildPackage,micropython-mpremote))
$(eval $(call BuildPackage,micropython-mpremote-src))
