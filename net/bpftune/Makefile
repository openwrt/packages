#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bpftune
PKG_VERSION:=0.4.2
PKG_RELEASE:=1

PKG_SOURCE:=bpftune-0.4-2.tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/oracle/bpftune/tar.gz/0.4-2?
PKG_HASH:=96a7de8491fa8b3b8f96a21784aac6d7e303f606a7b8622bed8568ff0143e6db
PKG_BUILD_DIR:=$(BUILD_DIR)/bpftune-0.4-2

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Shon Sebastian <fluffball3@proton.me>

PKG_BUILD_DEPENDS:=bpf-headers

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/bpf.mk

define Package/bpftune/default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://github.com/oracle/bpftune
endef

define Package/bpftune
  $(call Package/bpftune/default)
  TITLE:=BPF driven auto-tuning (needs TCP_CONG_HTCP and TCP_CONG_DCTCP)
  DEPENDS:=+@KERNEL_BPF_EVENTS +@KERNEL_CGROUPS +@KERNEL_CGROUP_BPF \
	   +kmod-tcp-bbr +libnl-route +libcap +libbpf \
	   $(BPF_DEPENDS)
endef

define Package/bpftune-full
  $(call Package/bpftune/default)
  TITLE:=bpftune with BTF support (might cause crashloops on limited hardware).
  DEPENDS:=+bpftune +@KERNEL_DEBUG_INFO +@KERNEL_DEBUG_INFO_BTF \
	   +@KERNEL_NAMESPACES +@KERNEL_NET_NS
endef

define Package/bpftune/description
  bpftune aims to provide lightweight, always-on auto-tuning of system
  behaviour. By using BPF observability features, we can continuously
  monitor and adjust system behaviour at a fine grain. (Needs TCP_CONG_HTCP
  and TCP_CONG_DCTCP from target/linux/generic/config-<version> manually enabled
  to function correctly. Runs on no-BTF mode).
endef

define Package/bpftune-full/description
  bpftune with BTF support for intended functionality. Needs TCP_CONG_HTCP
  and TCP_CONG_DCTCP from target/linux/generic/config-<version> manually enabled
  to function, and KERNEL_DEBUG_INFO_REDUCED disabled manually. This package enables
  KERNEL_NET_NS and KERNEL_DEBUG_INFO_BTF as well which might cause crashloops on
  limited hardware eg. single core cpu routers.
endef

bpf_srcarch=$(subst \
  aarch64,arm64,$(subst \
  armeb,arm,$(subst \
  i386,x86,$(subst \
  x86_64,x86,$(subst \
  loongarch64,loongarch,$(subst \
  mipsel,mips,$(subst \
  mips64,mips,$(subst \
  powerpc64,powerpc,$(subst \
  riscv64,riscv,$(1))))))))))

BPF_SRCARCH:=$(call bpf_srcarch,$(ARCH))

MAKE_FLAGS += \
	BPFTUNE_VERSION="$(PKG_VERSION)-$(PKG_RELEASE)" \
	SRCARCH="$(BPF_SRCARCH)" \
	BPF_TARGET="$(BPF_TARGET)" \
	BPF_CLANG="$(CLANG)" \
	LLVM_STRIP="$(LLVM_STRIP)" \
	PKG_BUILD_DIR=$(PKG_BUILD_DIR)

define Package/bpftune/conffiles
/etc/config/bpftune
endef

define Package/bpftune/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/bpftune $(1)/usr/sbin/bpftune
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/libbpftune.so.0.4.2 $(1)/usr/lib/libbpftune.so.0.4.2
	$(LN) libbpftune.so.0.4.2 $(1)/usr/lib/libbpftune.so
	$(INSTALL_DIR) $(1)/usr/lib/bpftune
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/tcp_buffer_tuner.so $(1)/usr/lib/bpftune
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/route_table_tuner.so $(1)/usr/lib/bpftune
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/neigh_table_tuner.so $(1)/usr/lib/bpftune
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/sysctl_tuner.so $(1)/usr/lib/bpftune
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/tcp_conn_tuner.so $(1)/usr/lib/bpftune
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/netns_tuner.so $(1)/usr/lib/bpftune
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/net_buffer_tuner.so $(1)/usr/lib/bpftune
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ip_frag_tuner.so $(1)/usr/lib/bpftune
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/udp_buffer_tuner.so $(1)/usr/lib/bpftune
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DATA) ./files/bpftune.confd $(1)/etc/config/bpftune
	$(INSTALL_BIN) ./files/bpftune.initd $(1)/etc/init.d/bpftune
endef

$(eval $(call BuildPackage,bpftune))

$(eval $(call BuildPackage,bpftune-full))
