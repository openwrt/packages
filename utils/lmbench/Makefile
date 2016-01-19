#
# Copyright (C) 2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lmbench
PKG_VERSION:=3.0-a9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=@SF/lmbench/
PKG_MD5SUM:=b3351a3294db66a72e2864a199d37cbf

PKG_BUILD_DEPENDS:=librpc

include $(INCLUDE_DIR)/package.mk

define Package/lmbench
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=lmbench microbenchmarks
  URL:=http://sourceforge.net/projects/lmbench
  MENU:=1
endef

define Package/lmbench/description
  lmbench is a series of micro benchmarks intended to measure basic operating
  system and hardware system metrics.
endef

define Package/lmbench/install
	true
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/src \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_CROSS)ar" \
		OS="$(ARCH)" \
		BASE="$(PKG_INSTALL_DIR)" \
		LDLIBS="-lrpc" \
		COMPILE="$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(TARGET_LDFLAGS)" \
		lmbench install
endef

define PartGen
define Package/lmbench-$(subst _,-,$(1))
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=$(1) microbenchmark
  URL:=http://sourceforge.net/projects/lmbench
  DEPENDS:=lmbench +librpc
endef
endef

define PartInstall
define Package/lmbench-$(subst _,-,$(1))/install
	$(INSTALL_DIR) $$(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/$(1) $$(1)/usr/sbin/$(1)
endef
endef

LMBENCH_FILES:= \
	bw_file_rd \
	bw_mem \
	bw_mmap_rd \
	bw_pipe \
	bw_tcp \
	bw_unix \
	cache \
	disk \
	enough \
	flushdisk \
	hello \
	lat_cmd \
	lat_connect \
	lat_ctx \
	lat_dram_page \
	lat_fcntl \
	lat_fifo \
	lat_fs \
	lat_http \
	lat_mem_rd \
	lat_mmap \
	lat_ops \
	lat_pagefault \
	lat_pipe \
	lat_pmake \
	lat_proc \
	lat_rand \
	lat_rpc \
	lat_select \
	lat_sem \
	lat_sig \
	lat_syscall \
	lat_tcp \
	lat_udp \
	lat_unix \
	lat_unix_connect \
	lat_usleep \
	line \
	lmdd \
	lmhttp \
	loop_o \
	memsize \
	mhz \
	msleep \
	par_mem \
	par_ops \
	stream \
	timing_o \
	tlb

$(foreach file,$(LMBENCH_FILES),$(eval $(call PartGen,$(file))))
$(foreach file,$(LMBENCH_FILES),$(eval $(call PartInstall,$(file))))

$(eval $(call BuildPackage,lmbench))
$(foreach file,$(LMBENCH_FILES),$(eval $(call BuildPackage,lmbench-$(subst _,-,$(file)))))
