#
# Copyright (C) 2017-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-zmq
PKG_VERSION:=22.2.1
PKG_RELEASE:=1

PYPI_NAME:=pyzmq
PKG_HASH:=6d18c76676771fd891ca8e0e68da0bbfb88e30129835c0ade748016adb3b6242

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING.BSD

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-zmq
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python bindings for 0MQ
  URL:=https://github.com/zeromq/pyzmq
  DEPENDS:=\
     +python3-light \
     +python3-asyncio\
     +python3-ctypes \
     +python3-distutils \
     +python3-logging \
     +libzmq
endef

define Package/python3-zmq/description
  This package contains Python bindings for 0MQ.
  0MQ is a lightweight and fast messaging implementation.
endef

define prepare_pyzmq_setup
	$(CP) ./files/setup.cfg $(PKG_BUILD_DIR)/setup.cfg
endef

Hooks/Configure/Post += prepare_pyzmq_setup

PYTHON3_PKG_SETUP_ARGS:= --zmq=$(PKG_BUILD_DIR)/zmq

$(eval $(call Py3Package,python3-zmq))
$(eval $(call BuildPackage,python3-zmq))
$(eval $(call BuildPackage,python3-zmq-src))
