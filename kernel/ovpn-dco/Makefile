#
# Copyright (C) 2021 Jianhui Zhao <zhaojh329@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=ovpn-backports
PKG_VERSION:=7.0.0.2026032400
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL= \
	https://build.openvpn.net/downloads/releases \
	https://swupdate.openvpn.net/community/releases
PKG_HASH:=509ca84cf2bb7b9300b282c11869fc1607b09339b562087e535d070d4c0d26a8
PKG_BUILD_PARALLEL:=1

PKG_MAINTAINER:=Jianhui Zhao <zhaojh329@gmail.com>
PKG_LICENSE:=GPL-2.0-only


include $(INCLUDE_DIR)/package.mk

define KernelPackage/ovpn-backports
  SUBMENU:=Network Support
  TITLE:=OpenVPN data channel offload
  DEPENDS:= \
	+kmod-udptunnel4 +IPV6:kmod-udptunnel6 \
	+kmod-crypto-chacha20poly1305 +kmod-crypto-lib-chacha20 +kmod-crypto-lib-poly1305
  # Note: TCP requires STREAM_PARSER but it can't be selected by out-of-tree
  # modules, so pull in AF_KCM for now. This needs to be patched on kernel
  # side.
  #KCONFIG:=CONFIG_STREAM_PARSER=y
  KCONFIG:=CONFIG_AF_KCM
  FILES:=$(PKG_BUILD_DIR)/drivers/net/ovpn/ovpn.ko
  AUTOLOAD:=$(call AutoLoad,30,ovpn)
endef

define KernelPackage/ovpn-backports/description
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

$(eval $(call KernelPackage,ovpn-backports))
