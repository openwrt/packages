# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato and Donald Hoskins

include $(TOPDIR)/rules.mk

PKG_NAME:=rust
PKG_VERSION:=1.72.0
PKG_RELEASE:=2

PKG_SOURCE:=rustc-$(PKG_VERSION)-src.tar.gz
PKG_SOURCE_URL:=https://static.rust-lang.org/dist/
PKG_HASH:=ea9d61bbb51d76b6ea681156f69f0e0596b59722f04414b01c6e100b4b5be3a1
HOST_BUILD_DIR:=$(BUILD_DIR)/host/rustc-$(PKG_VERSION)-src

PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>
PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT

HOST_BUILD_DEPENDS:=python3/host
PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ./rust-values.mk

define Package/rust
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Rust
  TITLE:=Rust Programming Language Compiler
  URL:=https://www.rust-lang.org/
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  BUILDONLY:=1
endef

define Package/rust/description
  Rust is a multi-paradigm, general-purpose programming language designed for performance
  and safety, especially safe concurrency. Rust is syntactically similar to C++, but can
  guarantee memory safety by using a borrow checker to validate references.
endef

# Rust-lang has an uninstall script
RUST_UNINSTALL:=$(CARGO_HOME)/lib/rustlib/uninstall.sh

# Target Flags
TARGET_CONFIGURE_ARGS = \
	--set=target.$(RUSTC_TARGET_ARCH).ar=$(TARGET_AR) \
	--set=target.$(RUSTC_TARGET_ARCH).cc=$(TARGET_CC_NOCACHE) \
	--set=target.$(RUSTC_TARGET_ARCH).cxx=$(TARGET_CXX_NOCACHE) \
	--set=target.$(RUSTC_TARGET_ARCH).linker=$(TARGET_CC_NOCACHE) \
	--set=target.$(RUSTC_TARGET_ARCH).ranlib=$(TARGET_RANLIB) \
	$(if $(CONFIG_USE_MUSL),--set=target.$(RUSTC_TARGET_ARCH).musl-root=$(TOOLCHAIN_DIR))

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
	--enable-missing-tools \
	--disable-sanitizers \
	--release-channel=stable \
	--enable-cargo-native-static \
	--set=llvm.download-ci-llvm=true \
	$(TARGET_CONFIGURE_ARGS)

define Host/Uninstall
	# Call the Uninstall script
	[ -f $(RUST_UNINSTALL) ] && \
		$(BASH) $(RUST_UNINSTALL) || echo No Uninstall
endef

define Host/Compile
	( \
		cd $(HOST_BUILD_DIR) ; \
		$(PYTHON) x.py --config ./config.toml dist build-manifest cargo llvm-tools \
			rustc rust-std rust-src ; \
	)
endef

define Host/Install
	( \
		cd $(HOST_BUILD_DIR)/build/dist ; \
		find -iname "*.xz" -exec tar -xJf {} \; ; \
		find ./* -type f -name install.sh -execdir sh {} --prefix=$(CARGO_HOME) --disable-ldconfig \; ; \
		\
		sed -e 's|@RUSTC_TARGET_ARCH@|$(RUSTC_TARGET_ARCH)|g' \
		    -e 's|@TARGET_CC_NOCACHE@|$(TARGET_CC_NOCACHE)|g' \
			$(CURDIR)/files/cargo-config > $(CARGO_HOME)/config.toml ; \
	)
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,rust))
