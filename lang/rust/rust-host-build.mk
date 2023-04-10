# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato and Donald Hoskins

ifeq ($(origin RUST_INCLUDE_DIR),undefined)
  RUST_INCLUDE_DIR:=$(dir $(lastword $(MAKEFILE_LIST)))
endif
include $(RUST_INCLUDE_DIR)/rust-values.mk

# $(1) path to the package (optional)
# $(2) additional arguments to cargo (optional)
define Host/Compile/Cargo
	( \
		cd $(HOST_BUILD_DIR) ; \
		export PATH="$(CARGO_HOME)/bin:$(PATH)" ; \
		CARGO_HOME=$(CARGO_HOME) \
		CC=$(HOSTCC_NOCACHE) \
		cargo install -v \
			--profile stripped \
			$(if $(RUST_PKG_FEATURES),--features "$(RUST_PKG_FEATURES)") \
			--root $(HOST_INSTALL_DIR) \
			--path "$(if $(strip $(1)),$(strip $(1)),.)" $(2) ; \
	)
endef

define Host/Uninstall/Cargo
	( \
		cd $(HOST_BUILD_DIR) ; \
		export PATH="$(CARGO_HOME)/bin:$(PATH)" ; \
		CARGO_HOME=$(CARGO_HOME) \
		CC=$(HOSTCC_NOCACHE) \
		cargo uninstall -v \
			--root $(HOST_INSTALL_DIR) || true ; \
	)
endef

define RustBinHostBuild
  define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin
	$(INSTALL_BIN) $(HOST_INSTALL_DIR)/bin/* $(STAGING_DIR_HOSTPKG)/bin/
  endef
endef

Host/Compile=$(call Host/Compile/Cargo)
Host/Uninstall=$(call Host/Uninstall/Cargo)
