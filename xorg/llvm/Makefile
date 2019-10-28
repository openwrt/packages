# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=llvm
PKG_VERSION:=7.0.1.src
_PKG_VERSION:=7.0.1
PKG_SOURCE_URL:=http://llvm.org/releases/$(_PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
#5.0.2_PKG_HASH:=d522eda97835a9c75f0b88ddc81437e5edbb87dc2740686cb8647763855c2b3c
#6.0.1_PKG_HASH:=b6d6c324f9c71494c0ccaf3dac1f16236d970002b42bb24a6c9e1634f7d0f4e2
PKG_HASH:=a38dfc4db47102ec79dcc2aa61e93722c5f6f06f0a961073bd84b78fb949419b

PKG_BUILD_DEPENDS:=llvm/host
HOST_BUILD_PARALLEL:=1
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
CMAKE_INSTALL=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/llvm
  SECTION:=devel
  CATEGORY:=Development
  DEPENDS:=+libllvm +libstdcpp
  TITLE:=low level virtual machine compiler system
  URL:=http://llvm.org/
endef

define Package/libllvm
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libffi +libstdcpp
  TITLE:=low level virtual machine shared library
  URL:=http://llvm.org/
endef

# speed up otherwise will take forewer but cosumes more memmory
NUM_CORES ?= $(shell grep -c "vendor_id" /proc/cpuinfo)
MAKE_FLAGS+=-j$(NUM_CORES)
HOST_MAKE_FLAGS+=-j$(NUM_CORES)

TARGET_CFLAGS+=$(TARGET_CPPFLAGS)

PKG_CMAKE_OPTS_COMMON= \
	-Wno-dev \
	-DCMAKE_BUILD_TYPE="MINSIZEREL" \
	-DLLVM_INCLUDE_TOOLS=ON \
	-DLLVM_BUILD_UTILS=OFF \
	-DLLVM_BUILD_EXAMPLES=OFF \
	-DLLVM_INCLUDE_EXAMPLES=OFF \
	-DLLVM_BUILD_TESTS=OFF \
	-DLLVM_INCLUDE_TESTS=OFF \
	-DLLVM_INCLUDE_GO_TESTS=OFF \
	-DLLVM_BUILD_DOCS=OFF \
	-DLLVM_INCLUDE_DOCS=OFF \
	-DLLVM_ENABLE_DOXYGEN=OFF \
	-DLLVM_ENABLE_SPHINX=OFF \
	-DLLVM_TARGETS_TO_BUILD="AMDGPU" \
	-DLLVM_ENABLE_TERMINFO=OFF \
	-DLLVM_ENABLE_ASSERTIONS=OFF \
	-DLLVM_ENABLE_WERROR=OFF \
	-DLLVM_ENABLE_ZLIB=OFF \
	-DLLVM_OPTIMIZED_TABLEGEN=ON \
	-DLLVM_APPEND_VC_REV=OFF \
	-DLLVM_ENABLE_LIBXML2=OFF \
	-DCMAKE_EXE_LINKER_FLAGS="-Wl,--reduce-memory-overheads -Wl,--hash-size=1021 " \
	-DLLVM_PARALLEL_LINK_JOBS=2 \
	-DLLVM_BUILD_EXTERNAL_COMPILER_RT=ON \
	-DLLVM_BUILD_LLVM_DYLIB=ON \
	-DLLVM_LINK_LLVM_DYLIB=ON \
	-DLLVM_ENABLE_RTTI=ON

#maybe future config option for other targets
#	-DLLVM_TARGETS_TO_BUILD="X86;ARM;AArch64;AMDGPU" \

CMAKE_OPTIONS += \
	$(PKG_CMAKE_OPTS_COMMON) \
	-DLLVM_BUILD_TOOLS=ON \
	-DLLVM_TABLEGEN=$(STAGING_DIR_HOSTPKG)/usr/lib/llvm/bin/llvm-tblgen \
	$(PKG_BUILD_DIR)/source

CMAKE_HOST_OPTIONS += \
	$(PKG_CMAKE_OPTS_COMMON) \
	-DLLVM_BUILD_TOOLS=OFF \
	-DCMAKE_INSTALL_PREFIX="$(STAGING_DIR_HOSTPKG)/usr/lib/llvm" \
	-DCMAKE_BUILD_WITH_INSTALL_RPATH=TRUE \
	-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH \
	-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH \
	-DCMAKE_INSTALL_RPATH="$(STAGING_DIR_HOSTPKG)/usr/lib/llvm/lib" \
	-DCMAKE_SKIP_RPATH=FALSE \
	$(HOST_BUILD_DIR)/source

define Build/Prepare
	$(call Build/Prepare/Default)
	mkdir -p $(PKG_BUILD_DIR)/source
	mv $(PKG_BUILD_DIR)/* $(PKG_BUILD_DIR)/source 2>/dev/null || :
	mv $(PKG_BUILD_DIR)/.* $(PKG_BUILD_DIR)/source 2>/dev/null || :
endef

define Host/Prepare
	$(call Host/Prepare/Default)
	mkdir -p $(HOST_BUILD_DIR)/source
	mv $(HOST_BUILD_DIR)/* $(HOST_BUILD_DIR)/source 2>/dev/null || :
	mv $(HOST_BUILD_DIR)/.* $(HOST_BUILD_DIR)/source 2>/dev/null || :
endef

define Host/Compile
	$(call Host/Compile/Default,llvm-tblgen)
	$(call Host/Compile/Default,llvm-config)
endef

define Host/Install
	$(call Host/Install/Default)
	$(CP) $(HOST_BUILD_DIR)/bin/llvm-config \
	$(STAGING_DIR_HOSTPKG)/usr/lib/llvm/bin/
endef

define Package/llvm/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin \
	$(1)/usr/
endef

define Package/libllvm/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libLLVM*.so* \
	$(1)/usr/lib
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libllvm))
$(eval $(call BuildPackage,llvm))
