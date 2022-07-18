-include $(TOPDIR)/package/feeds/packages/rust/rustc_targets.mk

# These RUSTFLAGS are common across all TARGETs
RUSTFLAGS += \
  -C linker=$(TOOLCHAIN_DIR)/bin/$(TARGET_CC_NOCACHE) \
  -C ar=$(TOOLCHAIN_DIR)/bin/$(TARGET_AR) \
  -C target-cpu=$(RUSTC_CPU_TYPE)

ifneq ($(RUST_TARGET_FEATURES),)
RUSTFLAGS += -C target-feature=$(RUST_TARGET_FEATURES)
endif

# Common Build Flags
CARGO_BUILD_FLAGS = \
  RUSTFLAGS="$(RUSTFLAGS)" \
  CARGO_HOME="$(CARGO_HOME)"

# This adds the rust environmental variables to Make calls
# MAKE_FLAGS += $(RUST_BUILD_FLAGS)

define RustPackage/Cargo/Update
	cd $(PKG_BUILD_DIR) && \
	$(CARGO_BUILD_FLAGS) cargo update $(1)
endef

define RustPackage/Cargo/Compile
	cd $(PKG_BUILD_DIR) && \
	  $(CARGO_BUILD_FLAGS) cargo build -v --release \
	    --target $(RUSTC_TARGET_ARCH) $(1)
endef
