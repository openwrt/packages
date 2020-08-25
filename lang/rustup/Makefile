# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=rustup
PKG_VERSION:=1.22.1
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rust-lang/rustup.git
PKG_SOURCE_DATE:=2020-07-08
PKG_SOURCE_VERSION:=995002f2b88e8eea1cdf4879fa9e7cdc402b4938
PKG_HASH:=f37a7b56b36e4acf24675d6d3794059c228b750f780654900d3f8a5cecd52695
PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ./rustc-triple.mk

define Package/rustup
  	SECTION:=lang
  	CATEGORY:=Languages
  	TITLE:=Rust Programming Language Installer
  	URL:=https://www.rust-lang.org/
endef

define Package/rustup/description
  The rustup package installs the Rust Programming Language (rustc/cargo)
  for use with packages that require Rust to compile.

  For Rust Support, add the following to the package:
  ***************************************************
  PKG_BUILD_DEPENDS:=rustup/host
  include ../../lang/rustup/rustc-triple.mk

  CONFIGURE_VARS += \
  	CARGO_HOME=$(BUILD_DIR_HOST)/.cargo \
  	RUSTUP_HOME=$(BUILD_DIR_HOST)/.rustup \
   	ac_cv_path_CARGO="$(BUILD_DIR_HOST)/.cargo/bin/cargo" \
    	ac_cv_path_RUSTC="$(BUILD_DIR_HOST)/.cargo/bin/rustc"

endef

RUSTUP_INIT_ARGS:= \
  	--profile default \
	--default-toolchain stable \
  	--target $(RUSTC_TARGET_ARCH)

define Host/Configure
	CARGO_HOME=$(BUILD_DIR_HOST)/.cargo \
	RUSTUP_HOME=$(BUILD_DIR_HOST)/.rustup \
	$(BUILD_DIR_HOST)/$(PKG_SOURCE_SUBDIR)/rustup-init.sh -y -v $(RUSTUP_INIT_ARGS)
endef

define Host/Compile
	true
endef

define Host/Install
	CARGO_HOME=$(BUILD_DIR_HOST)/.cargo \
	RUSTUP_HOME=$(BUILD_DIR_HOST)/.rustup \
	$(BUILD_DIR_HOST)/.cargo/bin/rustup toolchain install stable -t $(RUSTC_TARGET_ARCH)
endef

define Package/rustup/compile
endef

define Package/rustup/install
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,rustup))
