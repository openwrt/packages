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

PKG_BUILD_DIR:=$(BUILD_DIR)/evdev-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-evdev
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  URL:=https://github.com/gvalkov/python-evdev
  TITLE:=Bindings to the Linux input handling subsystem
  DEPENDS:= +python3-light +python3-ctypes
  VARIANT:=python3
endef

define Package/python3-evdev/description
  Bindings to the Linux input handling subsystem
endef

define Py3Build/Compile
	$(call Build/Compile/Py3Mod,, build \
		build_ecodes  --evdev-headers="$(LINUX_DIR)/include/uapi/linux/input.h:$(LINUX_DIR)/include/uapi/linux/input-event-codes.h" \
		build_ext \
		install --root="$(PKG_INSTALL_DIR)" --prefix="/usr")
endef

$(eval $(call Py3Package,python3-evdev))
$(eval $(call BuildPackage,python3-evdev))
