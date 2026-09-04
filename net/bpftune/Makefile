#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bpftune
PKG_VERSION:=0.4.2-f562f77
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/KyleGospo/bpftune.git
PKG_SOURCE_DATE:=2026-08-26
PKG_SOURCE_VERSION:=f562f776aac16478a2eeae1bf4871a66dd0070c3
PKG_MIRROR_HASH:=fb49aaad19ee711226b8bf62ded281e7346750c4e4d08909b2a37ac58765438c
PKG_BUILD_DIR:=$(BUILD_DIR)/$(if $(BUILD_VARIANT),bpftune-$(BUILD_VARIANT)/)bpftune-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0-WITH-Linux-syscall-note
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Shon Sebastian <fluffball3@proton.me>

PKG_BUILD_DEPENDS:=bpf-headers

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/bpf.mk

define Package/bpftune/default
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+@KERNEL_BPF_EVENTS +@KERNEL_CGROUPS +@KERNEL_CGROUP_BPF \
	   +kmod-tcp-bbr +libnl-route +libcap +libbpf \
	   $(BPF_DEPENDS)
endef

define Package/bpftune
  $(call Package/bpftune/default)
  URL:=https://github.com/oracle/bpftune
  TITLE:=BPF driven auto-tuning (needs TCP_CONG_HTCP and TCP_CONG_DCTCP)
  CONFLICTS:=bpftune-gaming bpftune-gaming-full
endef

define Package/bpftune-full
  $(call Package/bpftune/default)
  URL:=https://github.com/oracle/bpftune
  TITLE:=bpftune with BTF support (might cause crashloops on limited hardware).
  DEPENDS:=+bpftune +@KERNEL_DEBUG_INFO +@KERNEL_DEBUG_INFO_BTF \
	   +@KERNEL_NAMESPACES +@KERNEL_NET_NS
endef

define Package/bpftune-gaming
  $(call Package/bpftune/default)
  URL:=https://github.com/KyleGospo/bpftune
  TITLE:=Fork of bpftune with gaming tuner without BTF support (needs TCP_CONG_HTCP and TCP_CONG_DCTCP)
  VARIANT:=gaming
  CONFLICTS:=bpftune bpftune-full
endef

define Package/bpftune-gaming-full
  $(call Package/bpftune/default)
  URL:=https://github.com/KyleGospo/bpftune
  TITLE:=bpftune-gaming with BTF support (might cause crashloops on limited hardware)
  DEPENDS:=+bpftune-gaming +@KERNEL_DEBUG_INFO +@KERNEL_DEBUG_INFO_BTF \
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

define Package/bpftune-gaming/description
  Fork of bpftune which adds separate tuner and changes for gaming. (Needs
  TCP_CONG_HTCP and TCP_CONG_DCTCP from target/linux/generic/config-<version>
  manually enabled to function correctly. Runs on no-BTF mode).
endef

define Package/bpftune-gaming-full/description
  bpftune-gaming with BTF support for intended functionality. Needs TCP_CONG_HTCP
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
	PKG_BUILD_DIR=$(PKG_BUILD_DIR) \
	GAMING_BUILD=$(if $(filter gaming,$(BUILD_VARIANT)),true)

define Package/bpftune/conffiles
/etc/config/bpftune
endef
define Package/bpftune-gaming/conffiles
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

define Package/bpftune-gaming/install
	$(call Package/bpftune/install)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/gaming_tuner.so $(1)/usr/lib/bpftune
endef

$(eval $(call BuildPackage,bpftune))
$(eval $(call BuildPackage,bpftune-full))
$(eval $(call BuildPackage,bpftune-gaming))
$(eval $(call BuildPackage,bpftune-gaming-full))
