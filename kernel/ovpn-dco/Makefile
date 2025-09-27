#
# Copyright (C) 2021 Jianhui Zhao <zhaojh329@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=ovpn-dco
PKG_VERSION:=2025071800
PKG_VERSION_PREFIX:=net-6.16.0-rc6
PKG_VERSION_FULL:=$(PKG_VERSION_PREFIX)-$(PKG_VERSION)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL=https://codeload.github.com/OpenVPN/ovpn-backports/tar.gz/ovpn-net-next/$(PKG_VERSION_FULL)?
PKG_HASH:=8b893dd093a5549b34f8375e594024a0d4e2ab5f833c955e7aec1077c1ece754
PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/ovpn-backports-ovpn-net-next-$(PKG_VERSION_FULL)
PKG_BUILD_PARALLEL:=1

PKG_MAINTAINER:=Jianhui Zhao <zhaojh329@gmail.com>
PKG_LICENSE:=GPL-2.0-only


include $(INCLUDE_DIR)/package.mk

define KernelPackage/ovpn
  SUBMENU:=Network Support
  TITLE:=OpenVPN data channel offload
  DEPENDS:=+kmod-crypto-aead +kmod-udptunnel4 +IPV6:kmod-udptunnel6 +kmod-tls
  FILES:=$(PKG_BUILD_DIR)/drivers/net/ovpn/ovpn.ko
  AUTOLOAD:=$(call AutoLoad,30,ovpn)
  # Note: TCP requires STREAM_PARSER but it can't be selected by out-of-tree
  # modules, so pull in kmod-tls for now. This needs to be patched on kernel
  # side.
  #KCONFIG:=CONFIG_STREAM_PARSER=y
endef

define KernelPackage/ovpn/description
  This module enhances the performance of the OpenVPN userspace software
  by offloading the data channel processing to kernelspace.
endef

NOSTDINC_FLAGS += \
	$(KERNEL_NOSTDINC_FLAGS) \
	-I$(PKG_BUILD_DIR)/include \
	-I$(PKG_BUILD_DIR)/compat-include \
	-include $(PKG_BUILD_DIR)/linux-compat.h

EXTRA_KCONFIG:= \
	CONFIG_OVPN=m

PKG_EXTMOD_SUBDIRS = drivers/net/ovpn

MAKE_OPTS:= \
	M="$(PKG_BUILD_DIR)/$(PKG_EXTMOD_SUBDIRS)" \
	NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
	$(EXTRA_KCONFIG)

define Build/Compile
	+$(KERNEL_MAKE) $(PKG_JOBS) \
		$(MAKE_OPTS) \
		modules
endef

$(eval $(call KernelPackage,ovpn))
