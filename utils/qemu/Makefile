#
# Copyright (C) 2016 OpenWrt.org
# Copyright (C) 2016 Yousong Zhou <yszhou4tech@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qemu
PKG_VERSION:=2.6.2
PKG_RELEASE:=3
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://wiki.qemu-project.org/download/
PKG_SOURCE_MD5SUM:=bdf1f3d0c177ebeb35a079a4bc3fc74e
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE tcg/LICENSE
PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>

PKG_INSTALL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/uclibc++.mk
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
	$(if $(filter %-softmmu,$(1)),+libncurses +libfdt +qemu-blobs)
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
	--disable-nls		\
	, $(CONFIGURE_ARGS))

# Tell build system of qemu to not add _FORTIFY_SOURCE options and let the base
# build system decide flavor of fortify_source to use
CONFIGURE_ARGS +=			\
	--cross-prefix=$(TARGET_CROSS)	\
	--host-cc="$(HOSTCC)"		\
	--disable-fortify-source	\
	--disable-stack-protector	\

CONFIGURE_ARGS +=			\
	--audio-drv-list=''		\
	--disable-debug-info		\
	--disable-modules		\
	--disable-sdl			\
	--disable-qom-cast-debug	\
	--disable-virtfs		\
	--disable-vnc			\
	--disable-debug-tcg		\
	--disable-sparse		\
	--disable-strip			\
	--disable-vnc-sasl		\
	--disable-vnc-jpeg		\
	--disable-vnc-png		\
	--disable-uuid			\
	--disable-vde			\
	--disable-netmap		\
	--disable-xen			\
	--disable-xen-pci-passthrough	\
	--disable-xen-pv-domain-build	\
	--disable-brlapi		\
	--disable-bluez			\
	--disable-tcg-interpreter	\
	--disable-cap-ng		\
	--disable-spice			\
	--disable-libiscsi		\
	--disable-libnfs		\
	--disable-cocoa			\
	--disable-bsd-user		\
	--disable-curl			\
	--disable-linux-aio		\
	--disable-attr			\
	--disable-docs			\
	--disable-opengl		\
	--disable-rbd			\
	--disable-xfsctl		\
	--disable-smartcard		\
	--disable-libusb		\
	--disable-usb-redir		\
	--disable-zlib-test		\
	--disable-lzo			\
	--disable-snappy		\
	--disable-bzip2			\
	--disable-guest-agent-msi	\
	--disable-tools			\
	--disable-seccomp		\
	--disable-glusterfs		\
	--disable-archipelago		\
	--disable-gtk			\
	--disable-gnutls		\
	--disable-nettle		\
	--disable-gcrypt		\
	--disable-rdma			\
	--disable-vte			\
	--disable-virglrenderer		\
	--disable-tpm			\
	--disable-libssh2		\
	--disable-vhdx			\
	--disable-numa			\
	--disable-tcmalloc		\
	--disable-jemalloc		\
	--disable-strip			\
	--disable-werror		\

QEMU_CONFIGURE_TARGET_LIST := $(foreach target,$(QEMU_TARGET_LIST),$(if $(CONFIG_PACKAGE_qemu-$(target)),$(target)))
CONFIGURE_ARGS += --target-list='$(QEMU_CONFIGURE_TARGET_LIST)'

ifneq ($(CONFIG_PACKAGE_qemu-ga),)
CONFIGURE_ARGS += --enable-guest-agent
endif

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
	$(foreach target,$(QEMU_TARGET_LIST),$(if $(CONFIG_PACKAGE_qemu-$(target)),subdir-$(target))) \

define Build/Compile
	$(if $(strip $(QEMU_MAKE_TARGETS)),$(call Build/Compile/Default,$(QEMU_MAKE_TARGETS)))
endef

$(eval $(call BuildPackage,virtio-console-helper))
$(eval $(call BuildPackage,qemu-ga))
$(eval $(call BuildPackage,qemu-bridge-helper))
$(eval $(call BuildPackage,qemu-blobs))
$(foreach target,$(QEMU_TARGET_LIST), \
  $(eval $(call BuildPackage,qemu-$(target))) \
)
