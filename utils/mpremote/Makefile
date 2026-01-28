#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mpremote
PKG_VERSION:=1.21.0
PKG_RELEASE:=1

PYPI_NAME:=mpremote
PKG_HASH:=65bc94511f6ff499e901ab59462a5f0744ff7e2cf71d8c75700d14a89c54ed61

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=

PKG_BUILD_DEPENDS:=python-hatchling/host python-hatch-requirements-txt/host python-hatch-vcs/host

include ../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/mpremote
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Interacting remotely with MicroPython devices
  URL:=https://github.com/micropython/micropython
  DEPENDS:=+python3-light +python3-urllib +python3-pyserial
endef

define Package/mpremote/description
This CLI tool provides an integrated set of utilities to remotely
interact with and automate a MicroPython device over a serial
connection.
endef

$(eval $(call Py3Package,mpremote))
$(eval $(call BuildPackage,mpremote))
$(eval $(call BuildPackage,mpremote-src))
