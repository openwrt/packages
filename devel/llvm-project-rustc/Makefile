# ==============================================================================
# The LLVM Project is under the Apache License v2.0 with LLVM Exceptions:
# ==============================================================================
# See https://github.com/llvm/llvm-project/blob/main/llvm/LICENSE.TXT
#
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

PKG_NAME:=llvm-project-rustc
PKG_VERSION:=14.0
PKG_SUBVERSION:=0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2022-03-22
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION).$(PKG_SUBVERSION)-$(PKG_SOURCE_DATE)
PKG_SOURCE_URL:=https://github.com/rust-lang/llvm-project.git
PKG_SOURCE_VERSION:=fc10370ef7d91babf512c10505f8f2176bc8519d
PKG_MIRROR_HASH:=704a53aa6a685767858ddd56ee8033b1e32999b37ce0e8015fa417c0bde55044

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_SOURCE_SUBDIR)
HOST_BUILD_PARALLEL:=1
PKG_HOST_ONLY:=1

CMAKE_BINARY_SUBDIR := build
CMAKE_SOURCE_SUBDIR := llvm

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

LLVM_RUST_PREFIX = llvm-rust-$(PKG_VERSION).$(PKG_SUBVERSION).$(HOST_OS)-$(HOST_ARCH)

ifeq ($(HOST_OS),Linux)
USE_ZLIB=-DLLVM_ENABLE_ZLIB=ON
else
USE_ZLIB=-DLLVM_ENABLE_ZLIB=OFF
endif

CMAKE_HOST_INSTALL_PREFIX = $(STAGING_DIR_HOST)/$(LLVM_RUST_PREFIX)
CMAKE_HOST_OPTIONS += \
	-DCLANG_BUILD_EXAMPLES=OFF \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CROSSCOMPILING=True \
	-DCMAKE_INSTALL_LIBDIR=$(STAGING_DIR_HOST)/lib \
	-DCMAKE_SKIP_RPATH=OFF \
	-DLLVM_ENABLE_BINDINGS=OFF \
	-DLLVM_ENABLE_BACKTRACES=ON \
	-DLLVM_ENABLE_DOXYGEN=OFF \
	-DLLVM_ENABLE_LIBPFM=ON \
	-DLLVM_ENABLE_LIBEDIT=OFF \
	-DLLVM_ENABLE_LIBXML2=OFF \
	-DLLVM_ENABLE_LOCAL_SUBMODULE_VISIBILITY=ON \
	-DLLVM_ENABLE_NEW_PASS_MANAGER=True \
	-DLLVM_ENABLE_PIC=ON \
	-DLLVM_ENABLE_PLUGINS=ON \
	-DLLVM_ENABLE_SPHINX=OFF \
	-DLLVM_ENABLE_TERMINFO=OFF \
	-DLLVM_ENABLE_THREADS=ON \
	-DLLVM_ENABLE_UNWIND_TABLES=ON \
	-DLLVM_ENABLE_WARNINGS=ON \
	-DLLVM_ENABLE_Z3_SOLVER=OFF \
	$(USE_ZLIB) \
	-DLLVM_INCLUDE_BENCHMARKS=OFF \
	-DLLVM_INCLUDE_DOCS=OFF \
	-DLLVM_INCLUDE_EXAMPLES=OFF \
	-DLLVM_INCLUDE_TESTS=OFF \
	-DLLVM_INSTALL_UTILS=ON \
	-DLLVM_LINK_LLVM_DYLIB=ON \
	-DLLVM_PARALLEL_LINK_JOBS="$(NPROC)" \
	-DLLVM_TARGETS_TO_BUILD="AArch64;ARM;Mips;PowerPC;X86"

define Host/Install
	rm -rf $(STAGING_DIR_HOST)/llvm-rust*
	$(Host/Install/Default)
	ln -sf $(LLVM_RUST_PREFIX) $(STAGING_DIR_HOST)/llvm-rust
	ln -sf $(STAGING_DIR_HOST)/$(LLVM_RUST_PREFIX)/lib/libLLVM-14.so $(STAGING_DIR_HOST)/lib/libLLVM-14.so
	ln -sf $(STAGING_DIR_HOST)/$(LLVM_RUST_PREFIX)/lib/libLLVM-14.so $(STAGING_DIR_HOST)/lib/libLLVM.so
	ln -sf $(STAGING_DIR_HOST)/$(LLVM_RUST_PREFIX)/lib/libLLVM-14.so $(STAGING_DIR_HOST)/lib/libLLVM-14.0.1.so
	ln -sf $(STAGING_DIR_HOST)/$(LLVM_RUST_PREFIX)/lib/libLTO.so.14 $(STAGING_DIR_HOST)/lib/libLTO.so
	ln -sf $(STAGING_DIR_HOST)/$(LLVM_RUST_PREFIX)/lib/libRemarks.so.14 $(STAGING_DIR_HOST)/lib/libRemarks.so
	STRIP_KMOD= PATCHELF= STRIP=strip $(SCRIPT_DIR)/rstrip.sh $(STAGING_DIR_HOST)/llvm-rust
	echo "$(PKG_VERSION).$(PKG_SUBVERSION)" > $(CMAKE_HOST_INSTALL_PREFIX)/.llvm-version
endef

define Host/Uninstall
	rm -rf $(STAGING_DIR_HOST)/llvm-rust* $(STAGING_DIR_HOST)/lib/libLLVM-14.so $(STAGING_DIR_HOST)/lib/libLLVM.so \
	  $(STAGING_DIR_HOST)/lib/libLLVM-14.0.1.so	$(STAGING_DIR_HOST)/lib/libLTO.so $(STAGING_DIR_HOST)/lib/libRemarks.so
endef

$(eval $(call HostBuild))
# $(eval $(call BuildPackage,llvm-project-rustc))