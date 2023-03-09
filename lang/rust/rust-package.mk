# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato and Donald Hoskins

rust_mk_path:=$(dir $(lastword $(MAKEFILE_LIST)))
include $(rust_mk_path)rust-host.mk

# $(1) path to the package
# $(2) additional arguments to cargo
define Host/Compile/Cargo
	( \
		cd $(HOST_BUILD_DIR) ; \
		export PATH="$(CARGO_HOME)/bin:$(PATH)" ; \
		CARGO_HOME=$(CARGO_HOME) CC=$(HOSTCC) \
			cargo install -v --profile stripped --root $(HOST_INSTALL_DIR) --path "$(if $(strip $(1)),$(strip $(1)),.)" $(2) ; \
	)
endef

# $(1) path to the package
# $(2) additional arguments to cargo
define Build/Compile/Cargo
	( \
		cd $(PKG_BUILD_DIR) ; \
		export PATH="$(CARGO_HOME)/bin:$(PATH)" ; \
		CARGO_HOME=$(CARGO_HOME) TARGET_CFLAGS="$(TARGET_CFLAGS) $(RUST_CFLAGS)" TARGET_CC=$(TARGET_CC_NOCACHE) CC=cc \
			cargo install -v --profile stripped --target $(RUSTC_TARGET_ARCH) --root $(PKG_INSTALL_DIR) --path "$(if $(strip $(1)),$(strip $(1)),.)" $(2) ; \
	)
endef
