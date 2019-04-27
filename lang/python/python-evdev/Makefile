#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=python-evdev
PKG_VERSION:=1.2.0
PKG_RELEASE:=1

PKG_LICENSE:=BSD-3-Clause
PKG_MAINTAINER:=Paulo Costa <me@paulo.costa.nom.br>, Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_SOURCE:=evdev-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/e/evdev
PKG_HASH:=b03f5e1be5b4a5327494a981b831d251a142b09e8778eda1a8b53eba91100166

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-evdev-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-evdev/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  URL:=https://github.com/gvalkov/python-evdev
endef

define Package/python-evdev
$(call Package/python-evdev/Default)
  TITLE:=python-evdev
  DEPENDS:= \
     +PACKAGE_python-evdev:python-light \
     +PACKAGE_python-evdev:python-ctypes
  VARIANT:=python
endef

define Package/python3-evdev
$(call Package/python-evdev/Default)
  TITLE:=python3-evdev
  DEPENDS:= \
      +PACKAGE_python3-evdev:python3-light \
      +PACKAGE_python3-evdev:python3-ctypes
  VARIANT:=python3
endef


define Package/python-evdev/description
	Bindings to the Linux input handling subsystem
endef

define Package/python3-evdev/description
$(call Package/python-evdev/description)
.
(Variant for Python3)
endef

LINUX_EVDEV_HEADERS="$(LINUX_DIR)/include/uapi/linux/input.h:$(LINUX_DIR)/include/uapi/linux/input-event-codes.h"

PYTHON3_PKG_SETUP_GLOBAL_ARGS:= \
	build build_ecodes \
	--evdev-headers="$(LINUX_EVDEV_HEADERS)" \
	build_ext

PYTHON_PKG_SETUP_GLOBAL_ARGS:=$(PYTHON3_PKG_SETUP_GLOBAL_ARGS)

$(eval $(call PyPackage,python-evdev))
$(eval $(call BuildPackage,python-evdev))
$(eval $(call Py3Package,python3-evdev))
$(eval $(call BuildPackage,python3-evdev))
