# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato and Donald Hoskins

# Rust Environmental Vars
CONFIG_HOST_SUFFIX:=$(word 4, $(subst -, ,$(GNU_HOST_NAME)))
RUSTC_HOST_ARCH:=$(HOST_ARCH)-unknown-linux-$(CONFIG_HOST_SUFFIX)
CARGO_HOME:=$(STAGING_DIR)/host/cargo
CARGO_VARS:=

ifeq ($(CONFIG_USE_MUSL),y)
# Force linking of the SSP library for musl
ifdef CONFIG_PKG_CC_STACKPROTECTOR_REGULAR
  ifeq ($(strip $(PKG_SSP)),1)
    RUSTC_LDFLAGS += -lssp_nonshared
  endif
endif
ifdef CONFIG_PKG_CC_STACKPROTECTOR_STRONG
  ifeq ($(strip $(PKG_SSP)),1)
    TARGET_CFLAGS += -lssp_nonshared
  endif
endif
endif

ifeq ($(HOST_OS),Darwin)
  ifeq ($(HOST_ARCH),arm64)
    RUSTC_HOST_ARCH:=aarch64-apple-darwin
  endif
endif

# mips64 openwrt has a specific targed in rustc
ifeq ($(ARCH),mips64)
  RUSTC_TARGET_ARCH:=$(REAL_GNU_TARGET_NAME)
else
  RUSTC_TARGET_ARCH:=$(subst openwrt,unknown,$(REAL_GNU_TARGET_NAME))
endif

RUSTC_TARGET_ARCH:=$(subst muslgnueabi,musleabi,$(RUSTC_TARGET_ARCH))

ifeq ($(ARCH),i386)
  RUSTC_TARGET_ARCH:=$(subst i486,i586,$(RUSTC_TARGET_ARCH))
else ifeq ($(ARCH),riscv64)
  RUSTC_TARGET_ARCH:=$(subst riscv64,riscv64gc,$(RUSTC_TARGET_ARCH))
endif

# ARM Logic
ifeq ($(ARCH),arm)
  ifeq ($(CONFIG_arm_v7),y)
    RUSTC_TARGET_ARCH:=$(subst arm,armv7,$(RUSTC_TARGET_ARCH))
  endif

  ifeq ($(CONFIG_HAS_FPU),y)
    RUSTC_TARGET_ARCH:=$(subst musleabi,musleabihf,$(RUSTC_TARGET_ARCH))
  endif
endif

ifeq ($(ARCH),aarch64)
    RUST_CFLAGS:=-mno-outline-atomics
endif
