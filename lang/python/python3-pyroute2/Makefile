#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python3-pyroute2
PKG_VERSION:=0.5.6
PKG_RELEASE:=1

PKG_SOURCE:=pyroute2-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pyroute2
PKG_HASH:=deae0e6191a04c3ee213c6fae6ed779602ef5da5ca5e2fa533f27bc04326bfbe

PKG_BUILD_DIR:=$(BUILD_DIR)/pyroute2-$(PKG_VERSION)

PKG_MAINTAINER:=Martin Matějek <martin.matejek@nic.cz>
PKG_LICENSE:=GPL-2.0-or-later Apache-2.0
PKG_LICENSE_FILES:=LICENSE.GPL.v2 LICENSE.Apache.v2

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pyroute2
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python netlink library
  URL:=https://github.com/svinota/pyroute2
  DEPENDS:= \
	  +python3-light \
	  +python3-distutils \
	  +python3-logging \
	  +python3-multiprocessing \
	  +python3-sqlite3 \
	  +python3-ctypes
  VARIANT:=python3
endef

define Package/python3-pyroute2/description
  Pyroute2 is a pure Python netlink library.
  The library was started as an RTNL protocol implementation,
  but now it supports many netlink protocols.
endef

PYTHON3_PKG_SETUP_ARGS:=

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-src))
