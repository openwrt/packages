ifeq ($(CONFIG_RUST_DEBUG),y)
CONFIGURE_ARGS += --enable-debug
endif

ifeq ($(CONFIG_RUST_DOCS),y)
CONFIGURE_ARGS += --enable-docs
else
CONFIGURE_ARGS += --disable-docs
endif

ifeq ($(CONFIG_RUST_COMPILER_DOCS),y)
CONFIGURE_ARGS += --enable-compiler-docs
else
CONFIGURE_ARGS += --disable-compiler-docs
endif

ifeq ($(CONFIG_RUST_OPTIMIZE_TESTS),y)
CONFIGURE_ARGS += --enable-optimize-tests
endif

ifeq ($(CONFIG_RUST_PARALLEL),y)
CONFIGURE_ARGS += --enable-parallel-compiler
endif

ifeq ($(CONFIG_RUST_VERBOSE_TESTS),y)
CONFIGURE_ARGS += --enable-verbose-tests
endif

ifeq ($(filter $(CONFIG_RUST_CCACHE) $(CCACHE),y),)
CONFIGURE_ARGS += --enable-ccache
endif

ifeq ($(CONFIG_RUST_CCACHE),y)
CONFIGURE_ARGS += --enable-ccache
endif

ifeq ($(CONFIG_RUST_LLVM_STATIC),y)
CONFIGURE_ARGS += --enable-llvm-static-stdcpp
endif

ifeq ($(CONFIG_RUST_LLVM_SHARED),y)
CONFIGURE_ARGS += --enable-llvm-link-shared
endif

ifeq ($(CONFIG_RUST_CODEGEN_TESTS),y)
CONFIGURE_ARGS += --enable-codegen-tests
endif

ifeq ($(CONFIG_RUST_OPTION_CHECKING),y)
CONFIGURE_ARGS += --enable-option-checking
endif

ifeq ($(CONFIG_RUST_ENABLE_NINJA),y)
CONFIGURE_ARGS += --enable-ninja
endif

ifeq ($(CONFIG_RUST_LOCKED_DEPS),y)
CONFIGURE_ARGS += --enable-locked-deps
endif

ifeq ($(CONFIG_RUST_VENDOR),y)
CONFIGURE_ARGS += --enable-vendor
endif

ifeq ($(CONFIG_RUST_SANITIZERS),y)
CONFIGURE_ARGS += --enable-sanitizers
endif

ifeq ($(CONFIG_RUST_DIST_SRC),y)
CONFIGURE_ARGS += --enable-dist-src
endif

ifeq ($(CONFIG_RUST_CARGO_NATIVE_STATIC),y)
CONFIGURE_ARGS += --enable-cargo-native-static
endif

ifeq ($(CONFIG_RUST_PROFILER),y)
CONFIGURE_ARGS += --enable-profiler
endif

ifeq ($(CONFIG_RUST_FULL_TOOLS),y)
CONFIGURE_ARGS += --enable-full-tools
endif

ifeq ($(CONFIG_RUST_MISSING_TOOLS),y)
CONFIGURE_ARGS += --enable-missing-tools
endif

ifeq ($(CONFIG_RUST_USE_LIBCXX),y)
CONFIGURE_ARGS += --enable-use-libcxx
endif

ifeq ($(CONFIG_RUST_CONTROL_FLOW_GUARD),y)
CONFIGURE_ARGS += --enable-control-flow-guard
endif

ifeq ($(CONFIG_RUST_OPTIMIZE_LLVM),y)
CONFIGURE_ARGS += --enable-optimize-llvm
endif

ifeq ($(CONFIG_RUST_LLVM_ASSERTIONS),y)
CONFIGURE_ARGS += --enable-llvm-assertions
endif

ifeq ($(CONFIG_RUST_DEBUG_ASSERTIONS),y)
CONFIGURE_ARGS += --enable-debug-assertions
endif

ifeq ($(CONFIG_RUST_LLVM_RELEASE_DEBUGINFO),y)
CONFIGURE_ARGS += --enable-llvm-release-debuginfo
endif

ifeq ($(CONFIG_RUST_MANAGE_SUBMODULES),y)
CONFIGURE_ARGS += --enable-manage-submodules
endif

ifeq ($(CONFIG_RUST_FULL_BOOTSTRAP),y)
CONFIGURE_ARGS += --enable-full-bootstrap
endif
