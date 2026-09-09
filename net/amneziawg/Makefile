#
# Copyright (C) 2026 Karen Khachatryan <karen0734@gmail.com>
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=amneziawg
PKG_VERSION:=3.1.20260906
PKG_RELEASE:=1

PKG_SOURCE:=amneziawg-linux-kernel-module-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/amnezia-vpn/amneziawg-linux-kernel-module/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=e32fa46f1b6f9e319c5261f0b0765c3a9261e40cb7c4616fd73500da961a2932
PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/amneziawg-linux-kernel-module-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Karen Khachatryan <karen0734@gmail.com>

PKG_BUILD_PARALLEL:=1

MAKE_PATH:=src
PKG_EXTMOD_SUBDIRS:=src

include $(INCLUDE_DIR)/package.mk

define KernelPackage/amneziawg
  SUBMENU:=Network Support
  TITLE:=AmneziaWG VPN Kernel Module
  FILES:=$(PKG_BUILD_DIR)/$(MAKE_PATH)/amneziawg.ko
  AUTOLOAD:=$(call AutoProbe,amneziawg)
  DEPENDS:= \
    +kmod-udptunnel4 \
    +IPV6:kmod-udptunnel6 \
    +kmod-crypto-lib-chacha20poly1305 \
    +kmod-crypto-lib-curve25519
endef

define KernelPackage/amneziawg/description
  AmneziaWG is a WireGuard-derived VPN protocol with configurable traffic
  obfuscation. This package provides the AmneziaWG Linux kernel module.
endef

MAKE_OPTS:= \
	M="$(PKG_BUILD_DIR)/$(MAKE_PATH)" \
	WIREGUARD_VERSION="$(PKG_VERSION)"

define Build/Compile
	+$(KERNEL_MAKE) $(PKG_JOBS) \
		$(MAKE_OPTS) \
		modules
endef

$(eval $(call KernelPackage,amneziawg))
