#
# Copyright (C) 2018 Lim Guo Wei
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=coremark
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/eembc/coremark.git
PKG_SOURCE_DATE:=2023-01-25
PKG_SOURCE_VERSION:=d5fad6bd094899101a4e5fd53af7298160ced6ab
PKG_MIRROR_HASH:=e205f1d498bd00efbb057efa1876cc26e62eee9ebb73fb3024b47aab83e1814a

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
			This enables additional optmizations using the -O3 compilation flag.

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
	mkdir $(PKG_BUILD_DIR)/$(ARCH)
	$(CP) -r $(PKG_BUILD_DIR)/linux/* $(PKG_BUILD_DIR)/$(ARCH)
	$(MAKE) -C $(PKG_BUILD_DIR) PORT_DIR=$(ARCH) $(MAKE_FLAGS) \
		PORT_CFLAGS="$(TARGET_CFLAGS)" XCFLAGS="$(EXTRA_CFLAGS)" compile
endef

define Package/coremark/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/coremark $(1)/bin/
endef

$(eval $(call BuildPackage,coremark))
