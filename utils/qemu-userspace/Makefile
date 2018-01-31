#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qemu
PKG_VERSION:=2.11.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://download.qemu.org/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=c9d34a79024eae080ce3853aa9afe503824520eefb440190383003081ce7f437
PKG_LICENSE:=GPL-2.0

PKG_MAINTAINER:=Andy Walsh <andy.walsh44+github@gmail.com>

HOST_BUILD_PARALLEL:=1
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

HOST_BUILD_DEPENDS:=glib2/host zlib/host

define Package/qemu-userspace
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Virtualization
  TITLE:=qemu $(PKG_VERSION) (Linux/BSD User space emulation)
  URL:=https://www.qemu.org
  DEPENDS:=+glib2 +zlib +libpthread @BROKEN
endef

define Package/qemu-userspace/description
	QEMU is a generic and open source machine emulator and virtualizer. 
	(This package version is for user space emulation only, not full system.)
endef

HOST_CONFIGURE_ARGS +=	\
	--audio-drv-list=''		\
	--disable-debug-info	\
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
	--disable-werror		\
	--disable-stack-protector	\
	--disable-curl			\
	--disable-linux-aio		\
	--disable-attr			\
	--disable-crypto-afalg	\
	--disable-docs			\
	--disable-vhost-net		\
	--disable-vhost-scsi	\
	--disable-vhost-vsock	\
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
	--without-vss-sdk		\
	--without-win-sdk		\
	--disable-tools			\
	--disable-seccomp		\
	--disable-glusterfs		\
	--disable-gtk			\
	--disable-gnutls		\
	--disable-nettle		\
	--disable-gcrypt		\
	--disable-rdma			\
	--disable-vte			\
	--disable-virglrenderer	\
	--disable-tpm			\
	--disable-libssh2		\
	--disable-tcmalloc		\
	--disable-jemalloc		\
	--disable-strip			\
	--disable-replication	\
	--disable-vxhs			\
	--disable-system		\
	--disable-guest-agent	\
	--disable-pie			\
	--disable-live-block-migration \
	--disable-numa			\
	--disable-capstone		\
	--disable-git-update	\
	--disable-hax			\
	--disable-kvm			\
	--disable-blobs

#	--disable-tcg
#	--disable-bsd-user

# QEMU configure script does not recognize these options
HOST_CONFIGURE_ARGS:=$(filter-out	\
	--target=%		\
	--host=%		\
	--build=%		\
	--program-prefix=%	\
	--program-suffix=%	\
	--exec-prefix=%		\
	--disable-nls		\
	, $(HOST_CONFIGURE_ARGS))

# does this do anything in usermode?
CONFIGURE_ARGS:=$(filter-out	\
	--disable-hax	\
	--disable-kvm	\
	--disable-blobs	\
	, $(HOST_CONFIGURE_ARGS))
	
CONFIGURE_ARGS +=			\
	--cross-prefix=$(TARGET_CROSS)	\
	--host-cc="$(HOSTCC)"
	
$(eval $(call HostBuild))
$(eval $(call BuildPackage,qemu-userspace))
