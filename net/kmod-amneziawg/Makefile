include $(TOPDIR)/rules.mk

include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=kmod-amneziawg
PKG_VERSION:=1.0.20251104
PKG_RELEASE:=1
WIREGUARD_VERSION:=1.0.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/amnezia-vpn/amneziawg-linux-kernel-module.git
PKG_MIRROR_HASH:=32eeca0c579e60f62ee8e23c163afea0f9cf79727817c4a698a806a5d10f2cb9
PKG_SOURCE_VERSION:=866b0abe820d5a9c115fe3e4221132ecf8e39b94

PKG_MAINTAINER:=Gregory Gullin <garuwex@gmail.com>

include $(INCLUDE_DIR)/package.mk

define KernelPackage/amneziawg
	SECTION:=kernel
	CATEGORY:=Kernel modules
	SUBMENU:=Network Support
	URL:=https://amnezia.org/
	TITLE:=AmneziaWG Kernel Module

	DEPENDS:= \
		+kmod-crypto-lib-chacha20poly1305 \
		+kmod-crypto-lib-curve25519 \
		+kmod-udptunnel4 \
		+IPV6:kmod-udptunnel6
	FILES:=$(PKG_BUILD_DIR)/$(MAKE_PATH)/amneziawg.ko
	AUTOLOAD:=$(call AutoProbe,amneziawg)
endef

MAKE_PATH:=src

define KernelPackage/amneziawg/description
	This package provides the kernel module for AmneziaWG.
endef

define Build/Compile
	$(KERNEL_MAKE) \
		M="$(PKG_BUILD_DIR)/$(MAKE_PATH)" \
		EXTRA_CFLAGS="$(BUILDFLAGS)" \
		WIREGUARD_VERSION="$(WIREGUARD_VERSION)" \
		modules
endef

$(eval $(call KernelPackage,amneziawg))
