#
# Copyright (C) 2016 OpenWrt.org
# Copyright (C) 2016-2019 Yousong Zhou <yszhou4tech@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qemu
PKG_VERSION:=10.1.3
PKG_RELEASE:=1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://download.qemu.org/
PKG_HASH:=fbaa7a0d7a9a1deb5695b125916746ec28fe0de6275d4454f3e3bbaf8b339b53
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE tcg/LICENSE
PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>
PKG_CPE_ID:=cpe:/a:qemu:qemu

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_BUILD_FLAGS:=no-mips16

PKG_BUILD_DEPENDS+=spice-protocol
PKG_BUILD_DEPENDS+=python3/host

include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-host.mk

QEMU_DEPS_IN_GUEST := @(TARGET_x86||TARGET_x86_64||TARGET_armsr||TARGET_malta)
QEMU_DEPS_IN_HOST := @(TARGET_x86_64||TARGET_armsr_armv8||TARGET_sunxi)
QEMU_DEPS_IN_HOST += +libstdcpp
QEMU_DEPS_IN_HOST += $(ICONV_DEPENDS)

define Package/virtio-console-helper
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Virtualization
  TITLE:=Helper script for vportNpn virtio-console devices
  DEPENDS:=$(QEMU_DEPS_IN_GUEST)
endef

define Package/virtio-console-helper/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/virtio-ports
	$(INSTALL_BIN) ./files/00-virtio-ports.hotplug $(1)/etc/hotplug.d/virtio-ports/00-virtio-ports
endef


define Package/qemu-ga
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Virtualization
  TITLE:=QEMU Guest Agent
  URL:=https://www.qemu.org
  DEPENDS:= +glib2 +virtio-console-helper +libstdcpp +libudev $(QEMU_DEPS_IN_GUEST)
endef

define Package/qemu-ga/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/qemu-ga $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/qemu-ga.init $(1)/etc/init.d/qemu-ga
	$(INSTALL_DIR) $(1)/etc/hotplug.d/virtio-ports
	$(INSTALL_BIN) ./files/10-qemu-ga.hotplug $(1)/etc/hotplug.d/virtio-ports/10-qemu-ga
endef

PKG_CONFIG_DEPENDS += CONFIG_PACKAGE_qemu-ga


define Package/qemu-bridge-helper
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Virtualization
  TITLE:=QEMU bridge helper
  URL:=https://www.qemu.org
  DEPENDS:=+glib2 $(QEMU_DEPS_IN_HOST)
endef

define Package/qemu-bridge-helper/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/qemu-bridge-helper $(1)/usr/lib
	$(INSTALL_DIR) $(1)/etc/qemu
	$(INSTALL_DATA) ./files/bridge.conf $(1)/etc/qemu
endef


define Package/qemu-img
 SECTION:=utils
 CATEGORY:=Utilities
 SUBMENU:=Virtualization
 TITLE:=QEMU Image utility
 URL:=https://www.qemu.org
 DEPENDS:=+glib2 +QEMU_ZSTD:libzstd $(QEMU_DEPS_IN_HOST)
endef

define Package/qemu-img/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/qemu-img $(1)/usr/bin/qemu-img
endef


define Package/qemu-nbd
 SECTION:=utils
 CATEGORY:=Utilities
 SUBMENU:=Virtualization
 TITLE:=QEMU Network Block Device Utility
 URL:=https://www.qemu.org
 DEPENDS:=+glib2 +QEMU_ZSTD:libzstd $(QEMU_DEPS_IN_HOST) +kmod-nbd
endef

define Package/qemu-nbd/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/qemu-nbd $(1)/usr/sbin/qemu-nbd
endef


define qemu-firmware
  QEMU_PACKAGES += qemu-firmware-$(1)

  define Package/qemu-firmware-$(1)
    SECTION:=utils
    CATEGORY:=Utilities
    SUBMENU:=Virtualization
    TITLE:=$(qemu-firmware-$(1)-title)
    URL:=https://www.qemu.org
    DEPENDS:=$(QEMU_DEPS_IN_HOST)
  endef

  define Package/qemu-firmware-$(1)/install
	$$(INSTALL_DIR) $$(1)/usr/share/qemu
	$$(CP) $(foreach f,$(qemu-firmware-$(1)-files),$$(PKG_INSTALL_DIR)/usr/share/qemu/$(f)) $$(1)/usr/share/qemu
  endef
endef

qemu-firmware-seabios-title:=QEMU build of SeaBIOS for x86 guest
qemu-firmware-seabios-files:=bios.bin bios-256k.bin
$(eval $(call qemu-firmware,seabios))

qemu-firmware-seavgabios-title:=QEMU build of SeaVGABIOS
qemu-firmware-seavgabios-files:=vgabios-*.bin
$(eval $(call qemu-firmware,seavgabios))

qemu-firmware-pxe-title:=QEMU build of iPXE PXE roms
qemu-firmware-pxe-files:=pxe-*.rom
$(eval $(call qemu-firmware,pxe))

qemu-firmware-efi-title:=QEMU build of iPXE EFI roms
qemu-firmware-efi-files:=efi-*.rom
$(eval $(call qemu-firmware,efi))

define Package/qemu-keymaps
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Virtualization
  TITLE:=QEMU reverse keymaps for use with -k argument
  URL:=https://www.qemu.org
  DEPENDS:=$(QEMU_DEPS_IN_HOST)
endef

define Package/qemu-keymaps/install
	$(INSTALL_DIR) $(1)/usr/share/qemu/keymaps
	$(CP) $(PKG_INSTALL_DIR)/usr/share/qemu/keymaps/* $(1)/usr/share/qemu/keymaps
endef


# Naming rules used in qemu Makefile.target
define qemu-prog_
  $(if $(filter %-softmmu,$(1)), \
    $(patsubst %-softmmu,qemu-system-%,$(1)), \
    $(error unknown qemu target $(1)) \
  )
endef
qemu-prog = $(strip $(call qemu-prog_,$(1)))

# Why libfdt was enabled for all softmmu targets:  according to qemu's
# configure script, libfdt is only strictly required for the following targets
# and is optional for others.  But libfdt support will be built into other
# targets when any single target enabled it.
#
#	aarch64%-softmmu arm%-softmmu ppc%-softmmu microblaze%-softmmu
#
define qemu-target
  PKG_CONFIG_DEPENDS += CONFIG_PACKAGE_qemu-$(1)
  QEMU_PACKAGES += qemu-$(1)

  define Package/qemu-$(1)
    SECTION:=utils
    CATEGORY:=Utilities
    SUBMENU:=Virtualization
    TITLE:=QEMU target $(1)
    URL:=https://www.qemu.org
    DEPENDS:= +glib2 +libpthread +zlib +libbpf $(QEMU_DEPS_IN_HOST) $(qemu-target-$(1)-deps) \
	+QEMU_UI_VNC:qemu-keymaps \
	+QEMU_UI_VNC:libpng \
	+QEMU_UI_VNC_JPEG:libjpeg \
	+QEMU_UI_VNC_SASL:libsasl2 \
	+QEMU_UI_SPICE:libspice-server \
	+QEMU_DEV_USB:libusb-1.0 \
	+QEMU_SECCOMP:libseccomp \
	+QEMU_ZSTD:libzstd \
	$(if $(filter %-softmmu,$(1)),+libncurses +libfdt +libslirp +libudev +pixman +qemu-firmware-efi $(ICONV_DEPENDS))
  endef

  define Package/qemu-$(1)/description
    This package contains the QEMU target $(1)
  endef

  define Package/qemu-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(call qemu-prog,$(1)) $$(1)/usr/bin
	$(foreach f,$(qemu-target-$(1)-extra-files),
		$(INSTALL_DIR) $$(1)/$(dir $(f))
		$(CP) $(PKG_INSTALL_DIR)/$(f) $$(1)/$(f)
	)
  endef

endef

qemu-target-list :=	\
	x86_64-softmmu	\
	arm-softmmu	\
	aarch64-softmmu \

qemu-target-x86_64-softmmu-deps:= \
	+qemu-firmware-pxe \
	+qemu-firmware-seabios \
	+qemu-firmware-seavgabios
qemu-target-x86_64-softmmu-extra-files:= \
	usr/share/qemu/kvmvapic.bin \
	usr/share/qemu/linuxboot.bin \
	usr/share/qemu/linuxboot_dma.bin \
	usr/share/qemu/multiboot.bin \
	usr/share/qemu/pvh.bin

$(foreach target,$(qemu-target-list), \
  $(eval $(call qemu-target,$(target))) \
)

define Package/qemu-$(firstword $(qemu-target-list))/config
if $(subst $(space),||,$(foreach target,$(qemu-target-list),PACKAGE_qemu-$(target)))
config QEMU_UI_VNC
	bool "QEMU VNC support"
	default y

config QEMU_UI_VNC_JPEG
	bool "QEMU VNC jpeg tight encoding support"
	default n
	depends on QEMU_UI_VNC

config QEMU_UI_VNC_SASL
	bool "QEMU VNC SASL auth support"
	default n
	depends on QEMU_UI_VNC

config QEMU_UI_SPICE
	bool "QEMU SPICE ui support"

config QEMU_DEV_USB
	bool "QEMU USB passthrough support"
	default y

config QEMU_SECCOMP
	bool "Enable support for seccomp in QEMU"
	default KERNEL_SECCOMP
	help
	  Build QEMU with support for seccomp filters.
	  Select libseccomp which also pulls-in the needed kernel features.

config QEMU_ZSTD
	bool "QEMU ZSTD compression support"
	default n

endif
endef

PKG_CONFIG_DEPENDS += \
	CONFIG_QEMU_UI_VNC \
	CONFIG_QEMU_UI_VNC_JPEG \
	CONFIG_QEMU_UI_VNC_SASL \
	CONFIG_QEMU_UI_SPICE \
	CONFIG_QEMU_DEV_USB \
	CONFIG_QEMU_SECCOMP \
	CONFIG_QEMU_ZSTD \


# QEMU configure script does not recognize these options
CONFIGURE_ARGS:=$(filter-out	\
	--target=%		\
	--host=%		\
	--build=%		\
	--program-prefix=%	\
	--program-suffix=%	\
	--exec-prefix=%		\
	$(DISABLE_NLS)		\
	$(DISABLE_IPV6)		\
	, $(CONFIGURE_ARGS))

# Tell build system of qemu to not add _FORTIFY_SOURCE options and let the base
# build system decide flavor of fortify_source to use
CONFIGURE_ARGS +=			\
	--cross-prefix=$(TARGET_CROSS)	\
	--host-cc="$(HOSTCC)"		\
	--disable-fortify-source	\
	--disable-stack-protector	\
	--extra-cflags="$(TARGET_CFLAGS) $(EXTRA_CFLAGS)"	\
	--extra-cxxflags="$(TARGET_CXXFLAGS) $(EXTRA_CXXFLAGS)"	\
	--extra-ldflags="$(TARGET_LDFLAGS) $(EXTRA_LDFLAGS)"	\

# VHost features
CONFIGURE_ARGS +=			\
	--enable-vhost-crypto		\
	--enable-vhost-kernel		\
	--enable-vhost-net		\
	--enable-vhost-user		\
	--enable-vhost-user-blk-server	\
	--enable-vhost-vdpa		\

# Image formats support
CONFIGURE_ARGS +=			\
	--disable-bochs			\
	--disable-cloop			\
	--disable-dmg			\
	--disable-qcow1			\
	--disable-vdi			\
	--disable-vvfat			\
	--disable-qed			\
	--disable-parallels		\

# system/user-mode emulation
CONFIGURE_ARGS +=			\
	--disable-user			\
	--disable-bsd-user		\
	--disable-linux-user		\
	--enable-system			\

# accel
CONFIGURE_ARGS +=			\
	--disable-hvf			\
	--disable-whpx			\
	--disable-xen			\
	--enable-kvm			\
	--enable-tcg			\

# UI
CONFIGURE_ARGS +=			\
	--disable-cocoa			\
	--disable-gtk			\
	--disable-sdl			\
	--disable-sdl-image		\
	--$(if $(CONFIG_QEMU_UI_SPICE),enable,disable)-spice			\
	--disable-virglrenderer		\
	--$(if $(CONFIG_QEMU_UI_VNC),enable,disable)-vnc			\
	--$(if $(CONFIG_QEMU_UI_VNC_JPEG),enable,disable)-vnc-jpeg		\
	--$(if $(CONFIG_QEMU_UI_VNC_SASL),enable,disable)-vnc-sasl		\
	--disable-dbus-display		\
	--disable-vte			\
	--enable-curses			\
	--enable-iconv			\

# Features for performance & no external dependency
CONFIGURE_ARGS +=			\
	--enable-coroutine-pool		\
	--enable-crypto-afalg		\
	--enable-membarrier		\
	--enable-replication		\
	--enable-lto			\
	--enable-tools			\

# Review configure options not explicitly specified here
#
#	openwrt_makefile=openwrt/packages/utils/qemu/Makefile
#	qemu_configure=qemu/configure
#	for arg in $(grep -E '^\s*--disable-[^)]+\)' "$qemu_configure" | cut -f1 -d')'); do
#	  grep -qE "(--enable|--disable)${arg#--disable}" "$openwrt_makefile" || echo "$arg"
#	done
#
CONFIGURE_ARGS +=			\
	--audio-drv-list=''		\
	--disable-af-xdp                \
	--disable-attr			\
	--disable-auth-pam		\
	--disable-brlapi		\
	--disable-bzip2			\
	--disable-cap-ng		\
	--disable-capstone		\
	--disable-containers		\
	--disable-curl			\
	--disable-debug-info		\
	--disable-debug-mutex		\
	--disable-debug-tcg		\
	--disable-docs			\
	--disable-fuse			\
	--disable-gcrypt		\
	--disable-download		\
	--disable-glusterfs		\
	--disable-gnutls		\
	--disable-guest-agent-msi	\
	--disable-libiscsi		\
	--disable-libnfs		\
	--disable-libpmem		\
	--disable-libssh		\
	--$(if $(CONFIG_QEMU_DEV_USB),enable,disable)-libusb		\
	--disable-libkeyutils           \
	--disable-linux-aio		\
	--disable-linux-io-uring	\
	--disable-lzfse			\
	--disable-lzo			\
	--disable-modules		\
	--disable-module-upgrades	\
	--disable-mpath			\
	--disable-netmap		\
	--disable-nettle		\
	--disable-numa			\
	--disable-opengl		\
	--disable-plugins		\
	--disable-qom-cast-debug	\
	--disable-rbd			\
	--disable-rdma			\
	--disable-rust			\
	--disable-rutabaga-gfx          \
	--disable-asan			\
	--disable-tsan			\
	--disable-ubsan			\
	--disable-fuzzing		\
	--disable-safe-stack		\
	--$(if $(CONFIG_QEMU_SECCOMP),enable,disable)-seccomp		\
	--disable-smartcard		\
	--disable-snappy		\
	--disable-sparse		\
	--disable-strip			\
	--disable-tcg-interpreter	\
	--disable-tpm			\
	--disable-usb-redir		\
	--disable-vde			\
	--disable-virtfs		\
	--disable-werror		\
	--disable-xen-pci-passthrough	\
	--disable-xkbcommon		\
	--$(if $(CONFIG_QEMU_ZSTD),enable,disable)-zstd			\
	--disable-selinux		\
	--disable-oss			\
	--disable-alsa			\
	--disable-pa			\
	--disable-vduse-blk-export	\
	--disable-libdw			\

CONFIGURE_ARGS += --target-list='$(foreach target,$(qemu-target-list),$(if $(CONFIG_PACKAGE_qemu-$(target)),$(target)))'
CONFIGURE_ARGS += $(if $(CONFIG_PACKAGE_qemu-ga),--enable-guest-agent)

TARGET_LDFLAGS += -Wl,--as-needed
MAKE_VARS += V=1
# ARCH is special in qemu's build system, e.g. ARCH mips64 will be translated
# there to mips and stored in config-host.mak
MAKE_FLAGS:=$(filter-out	\
	ARCH=%			\
	,$(MAKE_FLAGS))

$(eval $(call BuildPackage,virtio-console-helper))
$(eval $(call BuildPackage,qemu-ga))
$(eval $(call BuildPackage,qemu-bridge-helper))
$(eval $(call BuildPackage,qemu-img))
$(eval $(call BuildPackage,qemu-nbd))
$(eval $(call BuildPackage,qemu-keymaps))
$(foreach p,$(QEMU_PACKAGES), \
  $(eval $(call BuildPackage,$(p))) \
)
