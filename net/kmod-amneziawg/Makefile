include $(TOPDIR)/rules.mk

include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=kmod-amneziawg
PKG_RELEASE:=1
WIREGUARD_VERSION:=1.0.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/amnezia-vpn/amneziawg-linux-kernel-module.git
PKG_MIRROR_HASH:=e3bac376719c2664d8c50cac231ad98e4aa9fe6091af88547160e9f961484348
PKG_SOURCE_VERSION:=d8a0f3d0c84dea67c35d352e4721b387a3d1cf0c

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
