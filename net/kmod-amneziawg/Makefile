include $(TOPDIR)/rules.mk

include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=kmod-amneziawg
PKG_RELEASE:=1
WIREGUARD_VERSION:=1.0.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/amnezia-vpn/amneziawg-linux-kernel-module.git
PKG_MIRROR_HASH:=a510149778f2c465806e32583078f76657ba90af43abecbd170df2f6e4d8d4f5
PKG_SOURCE_VERSION:=b91fabacfa5ef75ecf82d9c6fbf1df83fb403b57

MAKE_PATH:=src

include $(INCLUDE_DIR)/package.mk

define KernelPackage/amneziawg
	SECTION:=kernel
	CATEGORY:=Kernel modules
	SUBMENU:=Network Support
	URL:=https://amnezia.org/
	MAINTAINER:=Gregory Gullin <garuwex@gmail.com>
	TITLE:=AmneziaWG Kernel Module
	FILES:=$(PKG_BUILD_DIR)/$(MAKE_PATH)/generated/amneziawg.ko
	DEPENDS:= \
		+kmod-udptunnel4 \
		+IPV6:kmod-udptunnel6 \
		+kmod-crypto-kpp \
		+kmod-crypto-lib-chacha20poly1305 \
		+kmod-crypto-lib-curve25519
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	ln -sfn "$(LINUX_DIR)" "$(PKG_BUILD_DIR)/$(MAKE_PATH)/kernel"
endef

define Build/Compile
	$(MAKE_VARS) $(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/$(MAKE_PATH) $(MAKE_FLAGS) apply-patches
	$(MAKE_VARS) $(MAKE) -C "$(LINUX_DIR)" $(KERNEL_MAKE_FLAGS) M="$(PKG_BUILD_DIR)/$(MAKE_PATH)/generated" EXTRA_CFLAGS="$(BUILDFLAGS)" WIREGUARD_VERSION="$(WIREGUARD_VERSION)" modules
endef

$(eval $(call KernelPackage,amneziawg))
