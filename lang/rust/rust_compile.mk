define Host/Configure
	# Required because OpenWrt Default CONFIGURE_ARGS contain extra
	# args that cause errors
	cd $(HOST_BUILD_DIR) && \
	  ./configure $(CONFIGURE_ARGS)
endef

define Host/Compile
	cd $(HOST_BUILD_DIR) && \
	[ $(RUST_HOST_BINARY) ] && ( $(RUST_INSTALL_HOST_BINARIES) && \
	   $(PYTHON) x.py --config ./config.toml dist std ) || \
	   $(PYTHON) x.py --config ./config.toml dist cargo extended \
	      library/std llvm-tools miri
endef

define Host/Install
	cd $(HOST_BUILD_DIR)/build/dist && \
	   $(RM) *.gz && \
	   $(TAR) -cJf $(DL_DIR)/$(RUST_INSTALL_TARGET_FILE_NAME) \
	     rust-std-nightly-$(RUSTC_TARGET_ARCH).tar.xz

	[ $(RUST_HOST_BINARY) = false ] && \
	  cd $(HOST_BUILD_DIR)/build/dist && \
	  $(TAR) -cJf $(DL_DIR)/$(RUST_INSTALL_HOST_FILE_NAME) --exclude rust-std-nightly-$(RUSTC_TARGET_ARCH).tar.xz *.xz || \
	  true

	[ $(RUST_HOST_BINARY) = false ] && \
	sh $(RUST_INSTALL_HOST_BINARIES) || true

	sh $(RUST_INSTALL_TARGET_BINARIES)
endef
