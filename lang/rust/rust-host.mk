# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato and Donald Hoskins

# Rust Environmental Vars
CONFIG_HOST_SUFFIX:=$(word 4, $(subst -, ,$(GNU_HOST_NAME)))
RUSTC_HOST_ARCH:=$(HOST_ARCH)-unknown-linux-$(CONFIG_HOST_SUFFIX)
CARGO_HOME:=$(STAGING_DIR_HOST)/cargo

# Support only a subset for now.
RUST_ARCH_DEPENDS:=@(aarch64||arm||i386||i686||mips||mipsel||mips64||mips64el||mipsel||powerpc64||x86_64)

# Common Build Flags
RUST_BUILD_FLAGS = \
  CARGO_HOME="$(CARGO_HOME)"

# This adds the rust environmental variables to Make calls
MAKE_FLAGS += $(RUST_BUILD_FLAGS)

# Force linking of the SSP library
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

# mips64 openwrt has a specific targed in rustc
ifeq ($(ARCH),mips64)
  RUSTC_TARGET_ARCH:=$(REAL_GNU_TARGET_NAME)
else
  RUSTC_TARGET_ARCH:=$(subst openwrt,unknown,$(REAL_GNU_TARGET_NAME))
endif

RUSTC_TARGET_ARCH:=$(subst muslgnueabi,musleabi,$(RUSTC_TARGET_ARCH))

ifeq ($(ARCH),i386)
  RUSTC_TARGET_ARCH:=$(subst i486,i586,$(RUSTC_TARGET_ARCH))
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
