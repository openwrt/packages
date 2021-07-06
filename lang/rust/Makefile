# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=rust
PKG_VERSION:=1.50.0
PKG_RELEASE:=1

PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rust-lang/rust.git
PKG_SOURCE_DATE:=2021-02-10
PKG_SOURCE_VERSION:=cb75ad5db02783e8b0222fee363c5f63f7e2cf5b
PKG_MIRROR_HASH:=747c6a9f26d143e0ef95f1be4c6ac814e2d5eead1811cba797b04e71f720df02
PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/download.mk

HOST_BUILD_DEPENDS:=ninja/host python3/host
PKG_BUILD_DEPENDS:=rust/host
CMAKE_INSTALL:=1

# These are environment variables that are used by other packages to
# define where rustc/cargo are kept.
CONFIG_HOST_SUFFIX:=$(shell cut -d"-" -f4 <<<"$(GNU_HOST_NAME)")
RUSTC_HOST_ARCH:=$(HOST_ARCH)-unknown-linux-$(CONFIG_HOST_SUFFIX)
RUSTC_TARGET_ARCH:=$(REAL_GNU_TARGET_NAME)
CARGO_HOME:=$(STAGING_DIR_HOSTPKG)

# Basic Configuration Args that are used across all builds.
# Other build arguments are found in ./rustc-config.mk
#
# Default CONFIGURE_ARGS introduces unknown options - Use this instead
CONFIGURE_ARGS = \
  --host=$(RUSTC_HOST_ARCH) \
  --build=$(RUSTC_HOST_ARCH) \
  --target=$(RUSTC_TARGET_ARCH) \
  --prefix=$(CARGO_HOME) \
  --bindir=$(CARGO_HOME)/bin \
  --libdir=$(CARGO_HOME)/lib \
  --sysconfdir=$(CARGO_HOME)/etc \
  --datadir=$(CARGO_HOME)/share \
  --mandir=$(CARGO_HOME)/man \
  --infodir=$(CARGO_HOME)/info \
  --localstatedir=/var \
  --release-channel=nightly \
  --enable-lld

ifeq ($(CONFIG_USE_MUSL),y)
CONFIGURE_ARGS += \
  --set=target.$(RUSTC_TARGET_ARCH).linker=$(TARGET_CC_NOCACHE) \
  --set=target.$(RUSTC_TARGET_ARCH).cc=$(TARGET_CC_NOCACHE) \
  --set=target.$(RUSTC_TARGET_ARCH).cxx=$(TARGET_CXX_NOCACHE) \
  --set=target.$(RUSTC_TARGET_ARCH).ar=$(TARGET_AR) \
  --set=target.$(RUSTC_TARGET_ARCH).ranlib=$(TARGET_RANLIB)
endif

# Because we override CONFIGURE_ARGS, this needs to go here.
include ./rust_config.mk

RUST_TMP_DIR:=$(TMP_DIR)/rust-install
RUST_INSTALL_HOST_FILE_NAME:=$(PKG_NAME)-$(PKG_VERSION)-$(RUSTC_HOST_ARCH)-install.tar.xz
RUST_INSTALL_TARGET_FILE_NAME:=$(PKG_NAME)-$(PKG_VERSION)-$(RUSTC_TARGET_ARCH)-install.tar.xz

RUST_INSTALL_UNINSTALL:=$(CARGO_HOME)/lib/rustlib/uninstall.sh

RUST_INSTALL_HOST_BINARIES:=$(CURDIR)/install_binaries.sh $(RUST_TMP_DIR) $(DL_DIR)/$(RUST_INSTALL_HOST_FILE_NAME) $(CARGO_HOME)
RUST_INSTALL_TARGET_BINARIES:=$(CURDIR)/install_binaries.sh $(RUST_TMP_DIR) $(DL_DIR)/$(RUST_INSTALL_TARGET_FILE_NAME) $(CARGO_HOME)

RUST_HOST_BINARY:=$(or $(and $(wildcard $(DL_DIR)/$(RUST_INSTALL_HOST_FILE_NAME)),true),false)
RUST_TARGET_BINARY:=$(or $(and $(wildcard $(DL_DIR)/$(RUST_INSTALL_TARGET_FILE_NAME)),true),false)

# If the HOST Install doesn't exist, force building all the tools
ifeq ($(RUST_HOST_BINARY), false)
CONFIGURE_ARGS += \
  --enable-full-tools
endif

define Host/Uninstall
	[ -f $(RUST_INSTALL_UNINSTALL) ] && \
	    $(RUST_INSTALL_UNINSTALL) || echo No Uninstall Found

	rm -rf $(BUILD_DIR_HOST)/rust

	rm -rf $(RUST_TMP_DIR)
endef

define Host/Prepare
	# Allows outside packages to call $$(BUILD_DIR_HOST)/rust as the dir
	# rather than needing the version number.
	[ -L $(BUILD_DIR_HOST)/rust ] || \
	   (cd $(BUILD_DIR_HOST); ln -s "$(PKG_NAME)-$(PKG_VERSION)" rust)

	[ -d $(RUST_TMP_DIR) ] || \
	   mkdir -p $(RUST_TMP_DIR)

	$(call Host/Prepare/Default)
endef

ifeq ($(RUST_TARGET_BINARY),true)
include ./rust_install.mk
else
include ./rust_compile.mk
endif

define Package/rust
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Rust Programming Language Compiler
  URL:=https://www.rust-lang.org/
  DEPENDS:=+python3 +ninja +pkg-config +libopenssl +libyaml \
    +libyaml-cpp +libunwind +openssl-util +python3-yaml
endef

define Package/rust/description
  Rust lang
endef

define Package/rust/config
	source "$(SOURCE)/Config.in"
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,rust))
