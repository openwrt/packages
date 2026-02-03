#
# Copyright (C) 2018 Lim Guo Wei
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=coremark
PKG_SOURCE_DATE:=2025-05-01
PKG_SOURCE_VERSION:=1f483d5b8316753a742cbf5590caf5bd0a4e4777
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/eembc/coremark/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=4067e7f260218df13f2875d8f821a8ff32a84153c6e0759d7c89f96c0a8bf987
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_MAINTAINER:=Lim Guo Wei <limguowei@gmail.com> \
		Aleksander Jan Bajkowski <olek2@wp.pl>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_FLAGS:=no-mips16 lto

include $(INCLUDE_DIR)/package.mk

define Package/coremark
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=CoreMark Embedded Microprocessor Benchmark
  URL:=https://github.com/eembc/coremark
endef

define Package/coremark/description
  Embedded Microprocessor Benchmark
endef

define Package/coremark/config
	config COREMARK_OPTIMIZE_O3
		bool "Use all optimizations (-O3)"
		depends on PACKAGE_coremark
		default y
		help
			This enables additional optimizations using the -O3 compilation flag.

	config COREMARK_ENABLE_MULTITHREADING
		bool "Enable multithreading support"
		depends on PACKAGE_coremark
		default n
		help
			This enables multithreading support

	config COREMARK_NUMBER_OF_THREADS
		int "Number of threads"
		depends on COREMARK_ENABLE_MULTITHREADING
		default 2
		help
			Number of threads to run in parallel
endef

ifeq ($(CONFIG_COREMARK_OPTIMIZE_O3),y)
	TARGET_CFLAGS := $(filter-out -O%,$(TARGET_CFLAGS)) -O3
endif

ifeq ($(CONFIG_COREMARK_ENABLE_MULTITHREADING),y)
	EXTRA_CFLAGS := -DMULTITHREAD=$(CONFIG_COREMARK_NUMBER_OF_THREADS) -DUSE_PTHREAD
endif

define Build/Compile
	$(SED) 's|EXE = .exe|EXE =|' $(PKG_BUILD_DIR)/posix/core_portme.mak
	mkdir -p $(PKG_BUILD_DIR)/$(ARCH)
	$(CP) $(PKG_BUILD_DIR)/linux/* $(PKG_BUILD_DIR)/$(ARCH)/
	$(MAKE) -C $(PKG_BUILD_DIR) PORT_DIR=$(ARCH) $(MAKE_FLAGS) \
		PORT_CFLAGS="$(TARGET_CFLAGS)" XCFLAGS="$(EXTRA_CFLAGS)" compile
endef

define Package/coremark/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/coremark $(1)/bin/
endef

$(eval $(call BuildPackage,coremark))
