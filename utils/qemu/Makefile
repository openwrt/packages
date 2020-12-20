#
# Copyright (C) 2016 OpenWrt.org
# Copyright (C) 2016-2019 Yousong Zhou <yszhou4tech@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qemu
PKG_VERSION:=4.0.0
PKG_RELEASE:=2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=13a93dfe75b86734326f8d5b475fde82ec692d5b5a338b4262aeeb6b0fa4e469
PKG_SOURCE_URL:=http://download.qemu.org/
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE tcg/LICENSE
PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>
PKG_CPE_ID:=cpe:/a:qemu:qemu

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/package.mk


QEMU_DEPS_IN_GUEST := @(TARGET_x86_64||TARGET_armvirt||TARGET_arm64||TARGET_malta)
QEMU_DEPS_IN_HOST := @(TARGET_x86_64||TARGET_sunxi)

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
  URL:=http://www.qemu.org
  DEPENDS:= +glib2 +virtio-console-helper $(CXX_DEPENDS) $(QEMU_DEPS_IN_GUEST)
endef

define Package/qemu-ga/description
  This package contains the QEMU Guest Agent daemon
endef

define Package/qemu-ga/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/qemu-ga $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/qemu-ga.init $(1)/etc/init.d/qemu-ga
	$(INSTALL_DIR) $(1)/etc/hotplug.d/virtio-ports
	$(INSTALL_BIN) ./files/10-qemu-ga.hotplug $(1)/etc/hotplug.d/virtio-ports/10-qemu-ga
endef


define Package/qemu-blobs
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Virtualization
  TITLE:=QEMU blobs of BIOS, VGA BIOS and keymaps
  URL:=http://www.qemu.org
  DEPENDS:=$(QEMU_DEPS_IN_HOST)
endef

define Package/qemu-blobs/install
	$(INSTALL_DIR) $(1)/usr/share/qemu
	$(CP) $(PKG_INSTALL_DIR)/usr/share/qemu/* $(1)/usr/share/qemu
endef

define Package/qemu-bridge-helper
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Virtualization
  TITLE:=QEMU bridge helper
  URL:=http://www.qemu.org
  DEPENDS:=+glib2 $(CXX_DEPENDS) $(QEMU_DEPS_IN_HOST)
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
 URL:=http://www.qemu.org
 DEPENDS:=+glib2 $(CXX_DEPENDS) $(QEMU_DEPS_IN_HOST)
endef

define Package/qemu-img/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/qemu-img $(1)/usr/bin/qemu-img
endef

define Package/qemu-nbd
 SECTION:=utils
 CATEGORY:=Utilities
 SUBMENU:=Virtualization
 TITLE:=QEMU Network Block Device Utility
 URL:=http://www.qemu.org
 DEPENDS:=+glib2 $(CXX_DEPENDS) $(QEMU_DEPS_IN_HOST) +kmod-nbd
endef

define Package/qemu-nbd/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/qemu-nbd $(1)/usr/sbin/qemu-nbd
endef

PKG_CONFIG_DEPENDS += CONFIG_PACKAGE_qemu-ga

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

  define Package/qemu-$(1)
    SECTION:=utils
    CATEGORY:=Utilities
    SUBMENU:=Virtualization
    TITLE:=QEMU target $(1)
    URL:=http://www.qemu.org
    DEPENDS:= +glib2 +libpthread +zlib $(CXX_DEPENDS) $(QEMU_DEPS_IN_HOST) \
	$(if $(filter %-softmmu,$(1)),+libncurses +libfdt +pixman +qemu-blobs $(ICONV_DEPENDS))
  endef

  define Package/qemu-$(1)/description
    This package contains the QEMU target $(1)
  endef

  define Package/qemu-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(call qemu-prog,$(1)) $$(1)/usr/bin
  endef

endef

QEMU_TARGET_LIST :=	\
	x86_64-softmmu	\
	arm-softmmu	\

$(foreach target,$(QEMU_TARGET_LIST), \
  $(eval $(call qemu-target,$(target))) \
)

# QEMU configure script does not recognize these options
CONFIGURE_ARGS:=$(filter-out	\
	--target=%		\
	--host=%		\
	--build=%		\
	--program-prefix=%	\
	--program-suffix=%	\
	--exec-prefix=%		\
	--disable-ipv6		\
	--disable-nls		\
	, $(CONFIGURE_ARGS))

# Tell build system of qemu to not add _FORTIFY_SOURCE options and let the base
# build system decide flavor of fortify_source to use
CONFIGURE_ARGS +=			\
	--cross-prefix=$(TARGET_CROSS)	\
	--host-cc="$(HOSTCC)"		\
	--disable-fortify-source	\
	--disable-stack-protector	\

# VHost features
CONFIGURE_ARGS +=			\
	--enable-vhost-crypto		\
	--enable-vhost-kernel		\
	--enable-vhost-net		\
	--enable-vhost-scsi		\
	--enable-vhost-user		\
	--enable-vhost-vsock		\

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
	--disable-hax			\
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
	--disable-spice			\
	--disable-virglrenderer		\
	--disable-vnc			\
	--disable-vnc-jpeg		\
	--disable-vnc-png		\
	--disable-vnc-sasl		\
	--disable-vte			\
	--enable-curses			\
	--enable-iconv			\

# Features for performance & no external dependency
CONFIGURE_ARGS +=			\
	--enable-coroutine-pool		\
	--enable-crypto-afalg		\
	--enable-live-block-migration	\
	--enable-membarrier		\
	--enable-replication		\

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
	--disable-attr			\
	--disable-auth-pam		\
	--disable-bluez			\
	--disable-brlapi		\
	--disable-bzip2			\
	--disable-cap-ng		\
	--disable-capstone		\
	--disable-curl			\
	--disable-debug-info		\
	--disable-debug-mutex		\
	--disable-debug-tcg		\
	--disable-docs			\
	--disable-gcrypt		\
	--disable-git-update		\
	--disable-glusterfs		\
	--disable-gnutls		\
	--disable-guest-agent-msi	\
	--disable-jemalloc		\
	--disable-libiscsi		\
	--disable-libnfs		\
	--disable-libpmem		\
	--disable-libssh2		\
	--disable-libudev		\
	--disable-libusb		\
	--disable-libxml2		\
	--disable-linux-aio		\
	--disable-lzfse			\
	--disable-lzo			\
	--disable-modules		\
	--disable-mpath			\
	--disable-netmap		\
	--disable-nettle		\
	--disable-numa			\
	--disable-opengl		\
	--disable-pvrdma		\
	--disable-qom-cast-debug	\
	--disable-rbd			\
	--disable-rdma			\
	--disable-sanitizers		\
	--disable-seccomp		\
	--disable-sheepdog		\
	--disable-smartcard		\
	--disable-snappy		\
	--disable-sparse		\
	--disable-strip			\
	--disable-tcg-interpreter	\
	--disable-tcmalloc		\
	--disable-tools			\
	--disable-tpm			\
	--disable-usb-redir		\
	--disable-vde			\
	--disable-virtfs		\
	--disable-vxhs			\
	--disable-werror		\
	--disable-xen-pci-passthrough	\
	--disable-xfsctl		\

CONFIGURE_ARGS += --target-list='$(foreach target,$(QEMU_TARGET_LIST),$(if $(CONFIG_PACKAGE_qemu-$(target)),$(target)))'
CONFIGURE_ARGS += $(if $(CONFIG_PACKAGE_qemu-ga),--enable-guest-agent)

TARGET_LDFLAGS += -Wl,--as-needed
MAKE_VARS += V=s
# ARCH is special in qemu's build system, e.g. ARCH mips64 will be translated
# there to mips and stored in config-host.mak
MAKE_FLAGS:=$(filter-out	\
	ARCH=%			\
	,$(MAKE_FLAGS))

QEMU_MAKE_TARGETS := \
	$(if $(CONFIG_PACKAGE_qemu-ga),qemu-ga) \
	$(if $(CONFIG_PACKAGE_qemu-bridge-helper),qemu-bridge-helper) \
	$(if $(CONFIG_PACKAGE_qemu-img),qemu-img) \
	$(if $(CONFIG_PACKAGE_qemu-nbd),qemu-nbd) \
	$(foreach target,$(QEMU_TARGET_LIST),$(if $(CONFIG_PACKAGE_qemu-$(target)),subdir-$(target))) \

define Build/Compile
	$(if $(strip $(QEMU_MAKE_TARGETS)),$(call Build/Compile/Default,$(QEMU_MAKE_TARGETS)))
endef

$(eval $(call BuildPackage,virtio-console-helper))
$(eval $(call BuildPackage,qemu-ga))
$(eval $(call BuildPackage,qemu-bridge-helper))
$(eval $(call BuildPackage,qemu-img))
$(eval $(call BuildPackage,qemu-nbd))
$(eval $(call BuildPackage,qemu-blobs))
$(foreach target,$(QEMU_TARGET_LIST), \
  $(eval $(call BuildPackage,qemu-$(target))) \
)
