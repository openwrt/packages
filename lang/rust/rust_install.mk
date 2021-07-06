define Host/Configure
	true
endef

define Host/Compile
	true
endef

define Host/Install
	[ -d $(CARGO_HOME)/lib/rustlib/$(RUSTC_HOST_ARCH) ] && true || \
	   $(RM) -rf $(RUST_TMP_DIR) && mkdir -p $(RUST_TMP_DIR) && \
	   sh $(RUST_INSTALL_HOST_BINARIES)

	[ -d $(CARGO_HOME)/lib/rustlib/$(RUSTC_TARGET_ARCH) ] && true || \
	   $(RM) -rf $(RUST_TMP_DIR) && mkdir -p $(RUST_TMP_DIR) && \
	   sh $(RUST_INSTALL_TARGET_BINARIES)
endef
