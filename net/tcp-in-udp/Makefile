# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2025-2026 Chester A. Unal <chester.a.unal@arinc9.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=tcp-in-udp
PKG_RELEASE:=1

PKG_LICENSE:=AGPL-3.0-or-later
PKG_MAINTAINER:=Chester A. Unal <chester.a.unal@arinc9.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/multipath-tcp/tcp-in-udp.git
PKG_SOURCE_DATE:=2026-02-24
PKG_SOURCE_VERSION:=bf16ad0b1c43853abbcac2053241d28e2bb20d12
PKG_MIRROR_HASH:=9b5c1f97a6400de3d975366b4cfeceebf6b63eda202dcd51848978730855a878

PKG_BUILD_DEPENDS:=bpf-headers

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/bpf.mk

define Package/tcp-in-udp
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Lightweight TCP in UDP tunnel using eBPF
  DEPENDS:=+libbpf $(BPF_DEPENDS)
endef

# The CompileBPF definition uses -O2 for LLVM_OPT which causes failure to load
# the BPF programme. Use -O1 which works.
# $(call CompileBPF,$(PKG_BUILD_DIR)/tcp_in_udp_tc.c,-DBPF_PRINTK_UNSUPPORTED)
define Build/Compile
	$(CLANG) -g -target $(BPF_ARCH)-linux-gnu $(BPF_CFLAGS) -DBPF_PRINTK_UNSUPPORTED \
		-c $(PKG_BUILD_DIR)/tcp_in_udp_tc.c -o $(patsubst %.c,%.bc,$(PKG_BUILD_DIR)/tcp_in_udp_tc.c)
	$(LLVM_OPT) -O1 -mtriple=$(BPF_TARGET) < $(patsubst %.c,%.bc,$(PKG_BUILD_DIR)/tcp_in_udp_tc.c) > $(patsubst %.c,%.opt,$(PKG_BUILD_DIR)/tcp_in_udp_tc.c)
	$(LLVM_DIS) < $(patsubst %.c,%.opt,$(PKG_BUILD_DIR)/tcp_in_udp_tc.c) > $(patsubst %.c,%.S,$(PKG_BUILD_DIR)/tcp_in_udp_tc.c)
	$(LLVM_LLC) -march=$(BPF_TARGET) -mcpu=v3 -filetype=obj -o $(patsubst %.c,%.o,$(PKG_BUILD_DIR)/tcp_in_udp_tc.c) < $(patsubst %.c,%.S,$(PKG_BUILD_DIR)/tcp_in_udp_tc.c)
	$(CP) $(patsubst %.c,%.o,$(PKG_BUILD_DIR)/tcp_in_udp_tc.c) $(patsubst %.c,%.debug.o,$(PKG_BUILD_DIR)/tcp_in_udp_tc.c)
	$(LLVM_STRIP) --strip-debug $(patsubst %.c,%.o,$(PKG_BUILD_DIR)/tcp_in_udp_tc.c)
endef

define Package/tcp-in-udp/install
	$(INSTALL_DIR) $(1)/usr/lib/bpf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/tcp_in_udp_tc.o $(1)/usr/lib/bpf
endef

$(eval $(call BuildPackage,tcp-in-udp))
