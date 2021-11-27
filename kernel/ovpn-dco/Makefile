#
# Copyright (C) 2021 Jianhui Zhao <zhaojh329@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=ovpn-dco
PKG_SOURCE_DATE:=2021-10-05
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/OpenVPN/ovpn-dco.git
PKG_SOURCE_VERSION:=1017d4ada58a4c73f44ef671b6469ae168b6c6b0
PKG_MIRROR_HASH:=5938ca14c7b3235b60da227f43638556272dea325ddb658bce5e0dadaebb923e

PKG_MAINTAINER:=Jianhui Zhao <zhaojh329@gmail.com>
PKG_LICENSE:=GPL-2.0-only


include $(INCLUDE_DIR)/package.mk

define KernelPackage/ovpn-dco
  SUBMENU:=Network Support
  TITLE:=OpenVPN data channel offload
  DEPENDS:=+kmod-crypto-aead +kmod-udptunnel4 +kmod-udptunnel6
  FILES:=$(PKG_BUILD_DIR)/drivers/net/ovpn-dco/ovpn-dco.ko
  AUTOLOAD:=$(call AutoLoad,30,ovpn-dco)
endef

define KernelPackage/ovpn-dco/description
  This module enhances the performance of the OpenVPN userspace software
  by offloading the data channel processing to kernelspace.
endef

NOSTDINC_FLAGS += \
	$(KERNEL_NOSTDINC_FLAGS) \
	-I$(PKG_BUILD_DIR)/include \
	-include $(PKG_BUILD_DIR)/linux-compat.h

EXTRA_KCONFIG:= \
	CONFIG_OVPN_DCO=m

PKG_EXTMOD_SUBDIRS = drivers/net/ovpn-dco

MAKE_OPTS:= \
	$(KERNEL_MAKE_FLAGS) \
	M="$(PKG_BUILD_DIR)/drivers/net/ovpn-dco" \
	NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
	$(EXTRA_KCONFIG)

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		$(MAKE_OPTS) \
		modules
endef

$(eval $(call KernelPackage,ovpn-dco))
