include $(TOPDIR)/rules.mk

include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=kmod-amneziawg
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define KernelPackage/amneziawg
	SECTION:=kernel
	CATEGORY:=Kernel modules
	SUBMENU:=Network Support
	URL:=https://amnezia.org/
	TITLE:=AmneziaWG Kernel Module
	FILES:=$(PKG_BUILD_DIR)/amneziawg.ko
	DEPENDS:= \
		+kmod-udptunnel4 \
		+IPV6:kmod-udptunnel6 \
		+kmod-crypto-lib-chacha20poly1305 \
		+kmod-crypto-lib-curve25519
	AUTOLOAD:=$(call AutoProbe,amneziawg)
endef

define Build/Prepare
	cp -f $(LINUX_DIR)/drivers/net/wireguard/*.c $(PKG_BUILD_DIR)
	cp -f $(LINUX_DIR)/drivers/net/wireguard/*.h $(PKG_BUILD_DIR)
	cp -a $(LINUX_DIR)/drivers/net/wireguard/selftest $(PKG_BUILD_DIR)/
	mkdir -p $(PKG_BUILD_DIR)/uapi
	cp -f $(LINUX_DIR)/include/uapi/linux/wireguard.h $(PKG_BUILD_DIR)/uapi/
	for patch in `ls files/*`; do \
		patch -d $(PKG_BUILD_DIR)/ -F3 -t -p0 -i "$$$$(pwd)/$$$${patch}"; \
	done
	cp -f src/Makefile $(PKG_BUILD_DIR)
endef

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(BUILDFLAGS)" \
		modules
endef

$(eval $(call KernelPackage,amneziawg))
