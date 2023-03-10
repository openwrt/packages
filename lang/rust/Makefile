# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato and Donald Hoskins

include $(TOPDIR)/rules.mk

PKG_NAME:=rust
PKG_VERSION:=1.68.0
PKG_RELEASE:=1

PKG_SOURCE:=rustc-$(PKG_VERSION)-src.tar.gz
PKG_SOURCE_URL:=https://static.rust-lang.org/dist/
PKG_HASH:=eaf4d8b19f23a232a4770fb53ab5e7acdedec11da1d02b0e5d491ca92ca96d62
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/rustc-$(PKG_VERSION)-src/

PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>
PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT

HOST_BUILD_DEPENDS:=python3/host
PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

# rust environment variables
include ./rust-host.mk

# Rust Temp Directory
RUST_TMP_DIR:=$(TMP_DIR)/rust-install

RUST_INSTALL_HOST_FILENAME:=$(PKG_NAME)-$(PKG_VERSION)-$(RUSTC_HOST_ARCH)-install.tar.xz
RUST_INSTALL_TARGET_FILENAME:=$(PKG_NAME)-$(PKG_VERSION)-$(RUSTC_TARGET_ARCH)-install.tar.xz

# Rust-lang has an uninstall script
RUST_UNINSTALL:=$(CARGO_HOME)/lib/rustlib/uninstall.sh

# Target Flags
TARGET_CONFIGURE_ARGS = \
	--set=target.$(RUSTC_TARGET_ARCH).ar=$(TARGET_AR) \
	--set=target.$(RUSTC_TARGET_ARCH).cc=$(TARGET_CC_NOCACHE) \
	--set=target.$(RUSTC_TARGET_ARCH).cxx=$(TARGET_CXX_NOCACHE) \
	--set=target.$(RUSTC_TARGET_ARCH).linker=$(TARGET_CC_NOCACHE) \
	--set=target.$(RUSTC_TARGET_ARCH).musl-root=$(TOOLCHAIN_DIR) \
	--set=target.$(RUSTC_TARGET_ARCH).ranlib=$(TARGET_RANLIB)

# CARGO_HOME is an environmental
HOST_CONFIGURE_OPTS += CARGO_HOME="$(CARGO_HOME)"

# Rust Configuration Arguments
HOST_CONFIGURE_ARGS = \
	--build=$(RUSTC_HOST_ARCH) \
	--target=$(RUSTC_TARGET_ARCH),$(RUSTC_HOST_ARCH) \
	--host=$(RUSTC_HOST_ARCH) \
	--prefix=$(CARGO_HOME) \
	--bindir=$(CARGO_HOME)/bin \
	--libdir=$(CARGO_HOME)/lib \
	--sysconfdir=$(CARGO_HOME)/etc \
	--datadir=$(CARGO_HOME)/share \
	--mandir=$(CARGO_HOME)/man \
	--dist-compression-formats=xz \
	--enable-llvm-link-shared \
	--enable-llvm-plugins \
	--enable-missing-tools \
	--enable-ninja \
	--disable-sanitizers \
	--release-channel=stable \
	--enable-cargo-native-static \
	$(TARGET_CONFIGURE_ARGS)

define Host/Prepare
	# Ensure rust temp directory
	[ -d $(RUST_TMP_DIR) ] || \
	  mkdir -p $(RUST_TMP_DIR)

	$(call Host/Prepare/Default)
endef

define Host/Uninstall
	# Call the Uninstall script
	[ -f $(RUST_UNINSTALL) ] && \
	  $(BASH) $(RUST_UNINSTALL) || echo No Uninstall

	rm -rf $(RUST_TMP_DIR)
endef

# Makes and then packages the dist artifacts
define Host/Compile
	cd $(HOST_BUILD_DIR) && \
	  $(PYTHON) x.py --config ./config.toml dist build-manifest cargo llvm-tools \
	    rustc rust-std rust-src

	$(call Host/PackageDist)
endef

# Distribution Artifacts are packaged by Host/PackageDist
# We just need to extract and install
define Host/Install
	$(TAR) -C $(RUST_TMP_DIR) -xJf $(DL_DIR)/$(RUST_INSTALL_HOST_FILENAME) && \
	$(TAR) -C $(RUST_TMP_DIR) -xJf $(DL_DIR)/$(RUST_INSTALL_TARGET_FILENAME)

	cd $(RUST_TMP_DIR) && \
	  find -iname "*.xz" -exec tar -xJf {} ";" && \
	  find ./* -type f -name install.sh -execdir sh {} --prefix=$(CARGO_HOME) --disable-ldconfig \;

	echo -e "[target.$(RUSTC_TARGET_ARCH)]\nlinker = \"$(TARGET_CC_NOCACHE)\"\nrustflags = [\"-Ctarget-feature=-crt-static\", \"-Clink-args=$(RUSTC_LDFLAGS)\"]" > $(CARGO_HOME)/config
	echo -e "\n[profile.stripped]\ninherits = \"release\"\nopt-level = \"s\"\nstrip = true" >> $(CARGO_HOME)/config
endef

# Packages the Distribution Artifacts into HOST and TARGET bundles.
define Host/PackageDist
	( \
		cd $(HOST_BUILD_DIR)/build/dist ; \
		$(TAR) -cJf $(DL_DIR)/$(RUST_INSTALL_TARGET_FILENAME) \
			rust-*-$(RUSTC_TARGET_ARCH).tar.xz ; \
		$(TAR) -cJf $(DL_DIR)/$(RUST_INSTALL_HOST_FILENAME) \
			--exclude rust-*-$(RUSTC_TARGET_ARCH).tar.xz *.xz ; \
	)
endef

define Package/rust
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Rust Programming Language Compiler
  URL:=https://www.rust-lang.org/
  DEPENDS:=$(RUST_ARCH_DEPENDS) \
    +pkg-config +libunwind +libopenssl +liblzma +libc
endef

define Package/rust/description
  Rust is a multi-paradigm, general-purpose programming language designed for performance
  and safety, especially safe concurrency. Rust is syntactically similar to C++, but can
  guarantee memory safety by using a borrow checker to validate references.
endef

define Package/rust/config
	source "$(SOURCE)/Config.in"
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,rust))
