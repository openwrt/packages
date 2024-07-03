# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato and Donald Hoskins

# Clear environment variables which should be handled internally,
# as users might configure their own env on the host

# CCache
unexport RUSTC_WRAPPER

# Rust Environmental Vars
RUSTC_HOST_SUFFIX:=$(word 4, $(subst -, ,$(GNU_HOST_NAME)))
RUSTC_HOST_ARCH:=$(HOST_ARCH)-unknown-linux-$(RUSTC_HOST_SUFFIX)
CARGO_HOME:=$(DL_DIR)/cargo

ifeq ($(CONFIG_USE_MUSL),y)
  # Force linking of the SSP library for musl
  ifdef CONFIG_PKG_CC_STACKPROTECTOR_REGULAR
    ifeq ($(strip $(PKG_SSP)),1)
      RUSTC_LDFLAGS+=-lssp_nonshared
    endif
  endif
  ifdef CONFIG_PKG_CC_STACKPROTECTOR_STRONG
    ifeq ($(strip $(PKG_SSP)),1)
      RUSTC_LDFLAGS+=-lssp_nonshared
    endif
  endif
endif

CARGO_RUSTFLAGS+=-Ctarget-feature=-crt-static $(RUSTC_LDFLAGS)

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
  ifeq ($(CONFIG_arm_v6)$(CONFIG_arm_v7),)
    RUSTC_TARGET_ARCH:=$(subst arm,armv5te,$(RUSTC_TARGET_ARCH))
  else ifeq ($(CONFIG_arm_v7),y)
    RUSTC_TARGET_ARCH:=$(subst arm,armv7,$(RUSTC_TARGET_ARCH))
  endif

  ifeq ($(CONFIG_HAS_FPU),y)
    RUSTC_TARGET_ARCH:=$(subst musleabi,musleabihf,$(RUSTC_TARGET_ARCH))
    RUSTC_TARGET_ARCH:=$(subst gnueabi,gnueabihf,$(RUSTC_TARGET_ARCH))
  endif
endif

ifeq ($(ARCH),aarch64)
    RUSTC_CFLAGS:=-mno-outline-atomics
endif

# Support only a subset for now.
RUST_ARCH_DEPENDS:=@(aarch64||arm||i386||i686||mips||mipsel||mips64||mips64el||mipsel||powerpc64||riscv64||x86_64)

ifneq ($(CONFIG_RUST_SCCACHE),)
  RUST_SCCACHE_DIR:=$(if $(call qstrip,$(CONFIG_RUST_SCCACHE_DIR)),$(call qstrip,$(CONFIG_RUST_SCCACHE_DIR)),$(TOPDIR)/.sccache)

  RUST_SCCACHE_VARS:= \
	CARGO_INCREMENTAL=0 \
	RUSTC_WRAPPER=sccache \
	SCCACHE_DIR=$(RUST_SCCACHE_DIR)
endif

CARGO_HOST_CONFIG_VARS= \
	$(RUST_SCCACHE_VARS) \
	CARGO_HOME=$(CARGO_HOME)

CARGO_HOST_PROFILE:=release

CARGO_PKG_CONFIG_VARS= \
	$(RUST_SCCACHE_VARS) \
	CARGO_BUILD_TARGET=$(RUSTC_TARGET_ARCH) \
	CARGO_HOME=$(CARGO_HOME) \
	CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1 \
	CARGO_PROFILE_RELEASE_DEBUG=false \
	CARGO_PROFILE_RELEASE_DEBUG_ASSERTIONS=false \
	CARGO_PROFILE_RELEASE_LTO=true \
	CARGO_PROFILE_RELEASE_OPT_LEVEL=z \
	CARGO_PROFILE_RELEASE_OVERFLOW_CHECKS=true \
	CARGO_PROFILE_RELEASE_PANIC=unwind \
	CARGO_PROFILE_RELEASE_RPATH=false \
	CARGO_TARGET_$(subst -,_,$(call toupper,$(RUSTC_TARGET_ARCH)))_LINKER=$(TARGET_CC_NOCACHE) \
	RUSTFLAGS="$(CARGO_RUSTFLAGS)" \
	TARGET_CC=$(TARGET_CC_NOCACHE) \
	TARGET_CFLAGS="$(TARGET_CFLAGS) $(RUSTC_CFLAGS)"

CARGO_PKG_PROFILE:=$(if $(CONFIG_DEBUG),dev,release)
