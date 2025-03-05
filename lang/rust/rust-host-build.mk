# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato and Donald Hoskins

# Variables (all optional) to be set in package Makefiles:
#
# RUST_HOST_FEATURES - list of options, default empty
#
#   Space or comma separated list of features to activate
#
#   e.g. RUST_HOST_FEATURES:=enable-foo,with-bar

ifeq ($(origin RUST_INCLUDE_DIR),undefined)
  RUST_INCLUDE_DIR:=$(dir $(lastword $(MAKEFILE_LIST)))
endif
include $(RUST_INCLUDE_DIR)/rust-values.mk

CARGO_HOST_VARS= \
	$(CARGO_HOST_CONFIG_VARS) \
	CC=$(HOSTCC_NOCACHE) \
	MAKEFLAGS="$(HOST_JOBS)"

# $(1) path to the package (optional)
# $(2) additional arguments to cargo (optional)
define Host/Compile/Cargo
	+$(CARGO_HOST_VARS) \
	cargo install -v \
		--profile $(CARGO_HOST_PROFILE) \
		$(if $(RUST_HOST_FEATURES),--features "$(RUST_HOST_FEATURES)") \
		--root $(HOST_INSTALL_DIR) \
		--path "$(HOST_BUILD_DIR)/$(if $(strip $(1)),$(strip $(1)))" \
		$(if $(filter --jobserver%,$(HOST_JOBS)),,-j1) \
		$(2)
endef

define Host/Uninstall/Cargo
	+$(CARGO_HOST_VARS) \
	cargo uninstall -v \
		--root $(HOST_INSTALL_DIR) \
		|| true
endef

define RustBinHostBuild
  define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin
	$(INSTALL_BIN) $(HOST_INSTALL_DIR)/bin/* $(STAGING_DIR_HOSTPKG)/bin/
  endef
endef

Host/Compile=$(call Host/Compile/Cargo)
Host/Uninstall=$(call Host/Uninstall/Cargo)
