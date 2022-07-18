# Pull target info so we can type the CPU/CPU_SUBTYPE
target_conf=$(subst .,_,$(subst -,_,$(subst /,_,$(1))))
PLATFORM_DIR:=$(TOPDIR)/target/linux/$(BOARD)
SUBTARGET:=$(strip $(foreach subdir,$(patsubst $(PLATFORM_DIR)/%/target.mk,%,$(wildcard $(PLATFORM_DIR)/*/target.mk)),$(if $(CONFIG_TARGET_$(call target_conf,$(BOARD)_$(subdir))),$(subdir))))
PLATFORM_SUBDIR:=$(PLATFORM_DIR)$(if $(SUBTARGET),/$(SUBTARGET))
include $(PLATFORM_DIR)/Makefile
ifneq ($(PLATFORM_DIR),$(PLATFORM_SUBDIR))
  -include $(PLATFORM_SUBDIR)/target.mk
endif

# Rust Environmental Vars
CONFIG_HOST_SUFFIX:=$(shell cut -d"-" -f4 <<<"$(GNU_HOST_NAME)")
RUSTC_HOST_ARCH:=$(HOST_ARCH)-unknown-linux-$(CONFIG_HOST_SUFFIX)
RUSTC_TARGET_ARCH:=$(REAL_GNU_TARGET_NAME)
CARGO_HOME:=$(STAGING_DIR_HOST)/.cargo
LLVM_DIR:=$(STAGING_DIR_HOST)/llvm-rust
RUSTC_CPU_TYPE=$(CPU_TYPE)
RUSTFLAGS=
$(warning CPU_TYPE is $(RUSTC_CPU_TYPE))

# ARM Logic
ifeq ($(ARCH),arm)
$(warning Entering ARM)
  # Split out ARMv7
  ifeq ($(CONFIG_arm_v7),y)
    $(warning Target is ARMv7)
    RUSTC_TARGET_ARCH:=$(subst arm,armv7,$(RUSTC_TARGET_ARCH))
    # Set ARMv7 Soft-Float vs Hard-Float Instruction Sets
    ifeq ($(CONFIG_HAS_FPU),y)
      RUST_FEATURES += +v7 -d32 +thumb2
    else
      RUST_FEATURES += +v7 +thumb2 +soft-float
    endif
  endif

  # ARMv5
  ifeq ($(RUSTC_CPU_TYPE),arm926ej-s)
    RUSTC_TARGET_ARCH:=$(subst arm,armv5tej,$(RUSTC_TARGET_ARCH))
    RUST_FEATURES += +soft-float +strict-align
  endif

  # ARMv6 uses arm-openwrt-linux
  ifeq ($(RUSTC_CPU_TYPE),arm1176jzf-s)
    $(warning Target is ARMv6)
    RUST_FEATURES += +v6 +vfp2 -d32
  endif

  ifeq ($(RUSTC_CPU_TYPE),mpcore)
    $(warning Target is mpcore)
    RUSTC_TARGET_ARCH:=$(subst arm,armv6k,$(RUSTC_TARGET_ARCH))
    RUST_FEATURES += +v6 +soft-float +strict-align
  endif

  # Set Hard-Float ABI if TARGET has FPU
  ifeq ($(CONFIG_HAS_FPU),y)
    RUSTC_TARGET_ARCH:=$(RUSTC_TARGET_ARCH:muslgnueabi=muslgnueabihf)
  endif

  # CPU_SUBTYPE carries instruction flags in OpenWrt
  ifneq ($(CPU_SUBTYPE),)
    # NEON Support
    ifneq ($(findstring neon,$(CPU_SUBTYPE)),)
      RUST_FEATURES += +neon
    else
      RUST_FEATURES += -neon
    endif

    ###
    # vfpv prefix is not recognized by LLVM - convert to vfp and remove the
    # hyphen. This is important for CPU_SUBTYPE that use hyphenated CPU_SUBTYPE
    # like neon-vfpv4 and vfpv3-d16
    RUST_FEATURES += +$(lastword $(subst neon,,$(subst vfpv,vfp,$(subst -,,$(CPU_SUBTYPE)))))
  endif

  ###
  # If the RUST_FEATURES is empty or a single word, use as is, otherwise
  # split it into a Comma-delimited format for use with target-features
  ifneq ($(words $(RUST_FEATURES)),1)
      RUST_TARGET_FEATURES = $(subst $(space),$(comma),$(RUST_FEATURES))
  else
      RUST_TARGET_FEATURES = $(RUST_FEATURES)
  endif

  ifeq ($(RUSTC_CPU_TYPE),fa526)
   RUSTC_TARGET_ARCH:=$(subst arm,armv7,$(RUSTC_TARGET_ARCH))
   RUSTC_CPU_TYPE := generic
  endif
endif

# ARM Logic
ifeq ($(ARCH),mips64)
  RUSTC_CPU_TYPE := octeon+
endif

# AArch64 Flags
ifeq ($(ARCH),aarch64)
  RUSTFLAGS += -C link-arg=-lgcc
endif

$(warning RUST_TARGET_FEATURES is $(RUST_TARGET_FEATURES))