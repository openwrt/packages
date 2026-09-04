#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bpftune
PKG_VERSION:=0.4
PKG_RELEASE:=1

PKG_SOURCE:=bpftune-0.4-2.tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/oracle/bpftune/tar.gz/0.4-2?
PKG_HASH:=96a7de8491fa8b3b8f96a21784aac6d7e303f606a7b8622bed8568ff0143e6db
PKG_BUILD_DIR:=$(BUILD_DIR)/bpftune-0.4-2

PKG_LICENSE:=GPL-2.0 WITH Linux-syscall-note
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
  TITLE:=BPF driven auto-tuning (no-BTF by default)
  DEPENDS:=+@KERNEL_BPF_EVENTS +@KERNEL_CGROUPS +@KERNEL_CGROUP_BPF +@KERNEL_NAMESPACES +@KERNEL_NET_NS +libnl-route +libcap +libbpf
endef

define Package/bpftune-full
$(call Package/bpftune/default)
  TITLE:=bpftune with BTF support (might cause crashloops on limited hardware).
  DEPENDS:=+bpftune +@KERNEL_DEBUG_INFO +@KERNEL_DEBUG_INFO_BTF
endef

define Package/bpftune/description
  bpftune aims to provide lightweight, always-on auto-tuning of system
  behaviour. By using BPF observability features, we can continuously
  monitor and adjust system behaviour at a fine grain. (Runs on no-btf
  mode by default. Full functionality needs KERNEL_DEBUG_INFO_BTF enabled
  which might cause crashloops on limited hardware eg. single core cpu routers).
endef

define Package/bpftune-full/description
  bpftune with BTF support for intended functionality. Full functionality
  needs KERNEL_DEBUG_INFO_BTF enabled which might cause crashloops on limited
  hardware eg. single core cpu routers.
endef

CFLAGS += -DBPFTUNE_VERSION='"$(PKG_VERSION)-$(PKG_RELEASE)"'

MAKE_FLAGS += BPF_KARCH="$(BPF_KARCH)"

define Package/bpftune/conffiles
/etc/conf.d/bpftune
/etc/ld.so.conf.d/libbpftune.conf
endef

define Package/bpftune-full/conffiles
$(call Package/bpftune/conffiles)
endef

define Package/bpftune/install
		$(INSTALL_DIR) $(1)/usr/sbin
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/bpftune $(1)/usr/sbin/bpftune
		$(INSTALL_DIR) $(1)/usr/lib
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/libbpftune.so.0.4.2 $(1)/usr/lib/libbpftune.so.0.4.2
		$(LN) $(1)/usr/lib/libbpftune.so.0.4.2 $(1)/usr/lib/libbpftune.so
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
		$(INSTALL_DIR) $(1)/etc/ld.so.conf.d
		$(INSTALL_DIR) $(1)/etc/conf.d
		$(INSTALL_DIR) $(1)/etc/init.d
		$(INSTALL_DATA) ./files/bpftune.confd $(1)/etc/conf.d/bpftune
		$(INSTALL_BIN) ./files/bpftune.initd $(1)/etc/init.d/bpftune
		$(INSTALL_CONF) ./files/libbpftune.conf $(1)/etc/ld.so.conf.d/libbpftune.conf
endef

define Package/bpftune-full/install
$(call Package/bpftune/install)
endef

# This command is always the last, it uses the definitions and variables we give above in order to get the job done
$(eval $(call BuildPackage,bpftune))

$(eval $(call BuildPackage,bpftune-full))
