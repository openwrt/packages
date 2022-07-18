# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
include $(TOPDIR)/rules.mk

PKG_NAME:=rust_host
PKG_VERSION:=1.62.0
PKG_RELEASE:=1

PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rust-lang/rust.git
G_SOURCE_DATE:=2022-06-29
PKG_SOURCE_VERSION:=a8314ef7d0ec7b75c336af2c9857bfaf43002bfc
PKG_MIRROR_HASH:=09f933ee7a449751bc6d7ad6364dd44163439f029061daf158d7bfaf3a726184


PKG_SOURCE_SUBDIR:=rust-$(PKG_VERSION)
PKG_HOST_ONLY:=1

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/rust_host-$(PKG_VERSION)
HOST_BUILD_PARALLEL:=1
HOST_USE_NINJA:=1

HOST_BUILD_DEPENDS:=python3/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

TAR_CMD=$(HOST_TAR) --strip=1 -C $(1) $(TAR_OPTIONS) 
HOST_STAMP_PREPARED=$(HOST_BUILD_DIR)/.prepared_$(RUSTC_HOST_ARCH)
HOST_STAMP_BUILT=$(HOST_BUILD_DIR)/.built_$(RUSTC_HOST_ARCH)
HOST_STAMP_CONFIGURED=$(HOST_BUILD_DIR)/.configured_$(RUSTC_HOST_ARCH)
HOST_STAMP_INSTALLED=$(STAGING_DIR_HOST)/stamp/.rust_$(RUSTC_HOST_ARCH)_installed

# Rust Environmental Vars
CONFIG_HOST_SUFFIX:=$(shell cut -d"-" -f4 <<<"$(GNU_HOST_NAME)")
RUSTC_HOST_ARCH:=$(HOST_ARCH)-unknown-linux-$(CONFIG_HOST_SUFFIX)
RUSTC_TARGET_ARCH:=$(REAL_GNU_TARGET_NAME)
CARGO_HOME:=$(STAGING_DIR_HOST)/.cargo

# Common Build Flags
RUST_BUILD_FLAGS = \
  LD_LIBRARY_PATH=$(LLVM_DIR)/lib \
  CARGO_HOME="$(CARGO_HOME)" \
  CXXFLAGS=-DLLVM_RUSTLLVM

# Use External rust-lang specific LLVM
RUST_UNINSTALL:=$(STAGING_DIR_HOST)/lib/rustlib/uninstall.sh
RUST_TMP_DIR:=$(TMP_DIR)/rust-install

# Set Configure Environmentals
HOST_CONFIGURE_OPTS += CARGO_HOME="$(CARGO_HOME)"

# The Flags are Common between HOST and TARGET
RUST_COMMON_ARGS := \
  --build=$(RUSTC_HOST_ARCH) \
  --host=$(RUSTC_HOST_ARCH) \
  --dist-compression-formats=xz \
  --enable-llvm-link-shared \
  --enable-llvm-plugins \
  --enable-missing-tools \
  --enable-ninja \
  --enable-optimize \
  --enable-optimize-llvm \
  --enable-parallel-compiler \
  --enable-sanitizers \
  --release-channel=nightly \
  --prefix=$(STAGING_DIR_HOST) \
  --bindir=$(STAGING_DIR_HOST)/bin \
  --libdir=$(STAGING_DIR_HOST)/lib \
  --sysconfdir=$(STAGING_DIR_HOST)/etc \
  --datadir=$(STAGING_DIR_HOST)/share \
  --mandir=$(STAGING_DIR_HOST)/man \
  --set=build.extended=true

ifeq ($(CONFIG_CCACHE),y)
RUST_COMMON_ARGS += --set=llvm.ccache=true
endif

##
# Because OpenWrt uses default configure flags that are not recognized
# we override the default and set our own.
#
# Rust HOST Configuration Arguments
HOST_CONFIGURE_ARGS = \
  --target=$(RUSTC_HOST_ARCH) \
  $(RUST_COMMON_ARGS) \
  --set=llvm.targets="AArch64;ARM;Mips;PowerPC;X86" \
  --set=llvm.experimental-targets='' \
  --set=llvm.version-suffix='' \
  --set=llvm.link-jobs=0


define Host/Uninstall
	# Call the Uninstall script
	[ -f $(RUST_UNINSTALL) ] && \
	  $(BASH) $(RUST_UNINSTALL) || echo No Uninstall

	rm -rf $(RUST_TMP_DIR) $(CARGO_HOME)
	rm -rf $(STAGING_DIR_HOST)/llvm-rust* $(STAGING_DIR_HOST)/lib/libLLVM-14.so $(STAGING_DIR_HOST)/lib/libLLVM.so \
	  $(STAGING_DIR_HOST)/lib/libLLVM-14.0.1.so $(STAGING_DIR_HOST)/lib/libLTO.so $(STAGING_DIR_HOST)/lib/libRemarks.so
endef

LLVM_DIR:=$(STAGING_DIR_HOST)/llvm-rust
RUST_LLVM_DIR:=$(HOST_BUILD_DIR)/build/$(RUSTC_HOST_ARCH)/llvm

# Installation is done via Host/Compile
define Host/Install
	cp -rf $(RUST_LLVM_DIR) $(LLVM_DIR)
	ln -sf $(LLVM_DIR)/lib/libLLVM-14.so $(STAGING_DIR_HOST)/lib/libLLVM.so
	ln -sf $(LLVM_DIR)/lib/libLLVM-14.so $(STAGING_DIR_HOST)/lib/libLLVM-14.so
	ln -sf $(LLVM_DIR)/lib/libLLVM-14.so $(STAGING_DIR_HOST)/lib/libLLVM-14.0.1.so
	ln -sf $(LLVM_DIR)/lib/libLTO.so.14 $(STAGING_DIR_HOST)/lib/libLTO.so
	ln -sf $(LLVM_DIR)/lib/libRemarks.so.14 $(STAGING_DIR_HOST)/lib/libRemarks.so
endef

define Host/Prepare
	# Ensure rust temp directory
	[ -d $(RUST_TMP_DIR) ] || \
	  mkdir -p $(RUST_TMP_DIR)

	$(call Host/Prepare/Default)
endef

###
# Build out stage1 artifacts only, stage2 is not needed
# Only build out minimal tools required to build the tuples
define Host/Compile
	cd $(HOST_BUILD_DIR) && \
	CXXFLAGS='$(HOST_CXXFLAGS)' \
	  LD_LIBRARY_PATH=$(LLVM_DIR)/lib:$(STAGING_DIR_HOST)/lib \
	  CARGO_HOME="$(CARGO_HOME)" \
	  $(PYTHON) x.py install --config ./config.toml
endef
#	  $(PYTHON) x.py install --config ./config.toml --stage 1 cargo \
#	  library/std rustfmt src src/librustc

$(eval $(call HostBuild))
# $(eval $(call BuildPackage,rust_host))
