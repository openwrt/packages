#
# Copyright (C) 2018-2023 Jeffery To
# Copyright (C) 2025-2026 George Sapkin
#
# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

GO_VERSION_MAJOR_MINOR:=1.22
GO_VERSION_PATCH:=12
PKG_HASH:=012a7e1f37f362c0918c1dfa3334458ac2da1628c4b9cf4d9ca02db986e17d71

PKG_NAME:=golang-bootstrap
PKG_VERSION:=$(GO_VERSION_MAJOR_MINOR)$(if $(GO_VERSION_PATCH),.$(GO_VERSION_PATCH))
PKG_RELEASE:=1

GO_SOURCE_URLS:=https://go.dev/dl/ \
                https://dl.google.com/go/ \
                https://golang.google.cn/dl/ \
                https://mirrors.nju.edu.cn/golang/ \
                https://mirrors.ustc.edu.cn/golang/

PKG_SOURCE:=go$(PKG_VERSION).src.tar.gz
PKG_SOURCE_URL:=$(GO_SOURCE_URLS)

PKG_MAINTAINER:=George Sapkin <george@sapk.in>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:golang:go

PKG_HOST_ONLY:=1

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/go-$(PKG_VERSION)
HOST_BUILD_PARALLEL:=1

HOST_GO_PREFIX:=$(STAGING_DIR_HOSTPKG)
HOST_GO_VERSION_ID:=bootstrap
HOST_GO_ROOT:=$(HOST_GO_PREFIX)/lib/go-$(HOST_GO_VERSION_ID)

# From go tool dist list
HOST_GO_VALID_OS_ARCH:= \
  aix/ppc64 \
  android/386 \
  android/amd64 \
  android/arm \
  android/arm64 \
  darwin/amd64 \
  darwin/arm64 \
  dragonfly/amd64 \
  freebsd/386 \
  freebsd/amd64 \
  freebsd/arm \
  freebsd/arm64 \
  freebsd/riscv64 \
  illumos/amd64 \
  ios/amd64 \
  ios/arm64 \
  js/wasm \
  linux/386 \
  linux/amd64 \
  linux/arm \
  linux/arm64 \
  linux/loong64 \
  linux/mips \
  linux/mips64 \
  linux/mips64le \
  linux/mipsle \
  linux/ppc64 \
  linux/ppc64le \
  linux/riscv64 \
  linux/s390x \
  netbsd/386 \
  netbsd/amd64 \
  netbsd/arm \
  netbsd/arm64 \
  openbsd/386 \
  openbsd/amd64 \
  openbsd/arm \
  openbsd/arm64 \
  openbsd/ppc64 \
  plan9/386 \
  plan9/amd64 \
  plan9/arm \
  solaris/amd64 \
  wasip1/wasm \
  windows/386 \
  windows/amd64 \
  windows/arm \
  windows/arm64

BOOTSTRAP_SOURCE:=go1.4-bootstrap-20171003.tar.gz
BOOTSTRAP_SOURCE_URL:=$(GO_SOURCE_URLS)
BOOTSTRAP_HASH:=f4ff5b5eb3a3cae1c993723f3eab519c5bae18866b5e5f96fe1102f0cb5c3e52

BOOTSTRAP_BUILD_DIR:=$(HOST_BUILD_DIR)/.go_bootstrap

BOOTSTRAP_GO_VALID_OS_ARCH:= \
  darwin/386 \
  darwin/amd64 \
  dragonfly/386 \
  dragonfly/amd64 \
  freebsd/386 \
  freebsd/amd64 \
  freebsd/arm \
  linux/386 \
  linux/amd64 \
  linux/arm \
  netbsd/386 \
  netbsd/amd64 \
  netbsd/arm \
  openbsd/386 \
  openbsd/amd64 \
  plan9/386 \
  plan9/amd64 \
  solaris/amd64 \
  windows/386 \
  windows/amd64

BOOTSTRAP_1_17_SOURCE:=go1.17.13.src.tar.gz
BOOTSTRAP_1_17_SOURCE_URL:=$(GO_SOURCE_URLS)
BOOTSTRAP_1_17_HASH:=a1a48b23afb206f95e7bbaa9b898d965f90826f6f1d1fc0c1d784ada0cd300fd

BOOTSTRAP_1_17_BUILD_DIR:=$(HOST_BUILD_DIR)/.go_bootstrap_1.17

BOOTSTRAP_1_20_SOURCE:=go1.20.14.src.tar.gz
BOOTSTRAP_1_20_SOURCE_URL:=$(GO_SOURCE_URLS)
BOOTSTRAP_1_20_HASH:=1aef321a0e3e38b7e91d2d7eb64040666cabdcc77d383de3c9522d0d69b67f4e

BOOTSTRAP_1_20_BUILD_DIR:=$(HOST_BUILD_DIR)/.go_bootstrap_1.20

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../golang-compiler.mk
include ../golang-package.mk

PKG_UNPACK:=$(HOST_TAR) -C "$(PKG_BUILD_DIR)" --strip-components=1 -xzf "$(DL_DIR)/$(PKG_SOURCE)"
HOST_UNPACK:=$(HOST_TAR) -C "$(HOST_BUILD_DIR)" --strip-components=1 -xzf "$(DL_DIR)/$(PKG_SOURCE)"
BOOTSTRAP_UNPACK:=$(HOST_TAR) -C "$(BOOTSTRAP_BUILD_DIR)" --strip-components=1 -xzf "$(DL_DIR)/$(BOOTSTRAP_SOURCE)"
BOOTSTRAP_1_17_UNPACK:=$(HOST_TAR) -C "$(BOOTSTRAP_1_17_BUILD_DIR)" --strip-components=1 -xzf "$(DL_DIR)/$(BOOTSTRAP_1_17_SOURCE)"
BOOTSTRAP_1_20_UNPACK:=$(HOST_TAR) -C "$(BOOTSTRAP_1_20_BUILD_DIR)" --strip-components=1 -xzf "$(DL_DIR)/$(BOOTSTRAP_1_20_SOURCE)"

# Don't strip ELF executables in test data
RSTRIP:=:

ifeq ($(GO_TARGET_SPECTRE_SUPPORTED),1)
  PKG_CONFIG_DEPENDS+=CONFIG_GOLANG_SPECTRE
endif

define Package/golang-bootstrap
  $(call GoPackage/GoSubMenu)
  TITLE:=Go programming language (bootstrap)
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/golang-bootstrap/description
  The Go programming language is an open source project to make programmers more
  productive.

  Go is expressive, concise, clean, and efficient. Its concurrency mechanisms
  make it easy to write programs that get the most out of multicore and
  networked machines, while its novel type system enables flexible and modular
  program construction. Go compiles quickly to machine code yet has the
  convenience of garbage collection and the power of run-time reflection. It's a
  fast, statically typed, compiled language that feels like a dynamically typed,
  interpreted language.
endef

define Package/golang-bootstrap/config
	source "$(SOURCE)/Config.in"
endef

BOOTSTRAP_ROOT_DIR:=$(call qstrip,$(CONFIG_GOLANG_EXTERNAL_BOOTSTRAP_ROOT))

ifeq ($(BOOTSTRAP_ROOT_DIR),)
  BOOTSTRAP_ROOT_DIR:=$(BOOTSTRAP_BUILD_DIR)

  define Download/golang-bootstrap
    FILE:=$(BOOTSTRAP_SOURCE)
    URL:=$(BOOTSTRAP_SOURCE_URL)
    HASH:=$(BOOTSTRAP_HASH)
  endef
  $(eval $(call Download,golang-bootstrap))

  define Bootstrap/Prepare
	mkdir -p "$(BOOTSTRAP_BUILD_DIR)" && $(BOOTSTRAP_UNPACK) ;
  endef
  Hooks/HostPrepare/Post+=Bootstrap/Prepare

  $(eval $(call GoCompiler/AddProfile,Bootstrap,$(BOOTSTRAP_BUILD_DIR),,bootstrap,$(GO_HOST_OS_ARCH)))
endif

# Skip configuring and downloading stages when building is not configured
ifeq ($(CONFIG_GOLANG_BUILD_BOOTSTRAP),y)

# Bootstrap 1.17

define Download/golang-bootstrap-1.17
  FILE:=$(BOOTSTRAP_1_17_SOURCE)
  URL:=$(BOOTSTRAP_1_17_SOURCE_URL)
  HASH:=$(BOOTSTRAP_1_17_HASH)
endef
$(eval $(call Download,golang-bootstrap-1.17))

define Bootstrap-1.17/Prepare
	mkdir -p "$(BOOTSTRAP_1_17_BUILD_DIR)" && $(BOOTSTRAP_1_17_UNPACK) ;
endef
Hooks/HostPrepare/Post+=Bootstrap-1.17/Prepare

$(eval $(call GoCompiler/AddProfile,Bootstrap-1.17,$(BOOTSTRAP_1_17_BUILD_DIR),,bootstrap-1.17,$(GO_HOST_OS_ARCH)))

# Bootstrap 1.20

define Download/golang-bootstrap-1.20
  FILE:=$(BOOTSTRAP_1_20_SOURCE)
  URL:=$(BOOTSTRAP_1_20_SOURCE_URL)
  HASH:=$(BOOTSTRAP_1_20_HASH)
endef
$(eval $(call Download,golang-bootstrap-1.20))

define Bootstrap-1.20/Prepare
	mkdir -p "$(BOOTSTRAP_1_20_BUILD_DIR)" && $(BOOTSTRAP_1_20_UNPACK) ;
endef
Hooks/HostPrepare/Post+=Bootstrap-1.20/Prepare

$(eval $(call GoCompiler/AddProfile,Bootstrap-1.20,$(BOOTSTRAP_1_20_BUILD_DIR),,bootstrap-1.20,$(GO_HOST_OS_ARCH)))

endif

# Host

ifeq ($(GO_HOST_PIE_SUPPORTED),1)
  HOST_GO_ENABLE_PIE:=1
endif

# When using GO_LDFLAGS to set buildmode=pie, the PIE install suffix does not
# apply (we also delete the std lib during Host/Install)

ifeq ($(CONFIG_GOLANG_BUILD_BOOTSTRAP),y)
  $(eval $(call GoCompiler/AddProfile,Host,$(HOST_BUILD_DIR),$(HOST_GO_PREFIX),$(HOST_GO_VERSION_ID),$(GO_HOST_OS_ARCH)))
endif

HOST_GO_VARS= \
	GOHOSTARCH="$(GO_HOST_ARCH)" \
	GOCACHE="$(GO_BUILD_CACHE_DIR)" \
	GOENV=off \
	CC="$(HOSTCC_NOCACHE)" \
	CXX="$(HOSTCXX_NOCACHE)"

define Host/Configure
	$(call GoCompiler/Bootstrap/CheckHost,$(BOOTSTRAP_GO_VALID_OS_ARCH))
	$(call GoCompiler/Host/CheckHost,$(HOST_GO_VALID_OS_ARCH))

	mkdir -p "$(GO_BUILD_CACHE_DIR)"
endef

define Host/Compile
	$(call GoCompiler/Bootstrap/Make, \
		$(HOST_GO_VARS) \
		CC="$(HOSTCC_NOCACHE) -std=gnu17" \
	)

	$(call GoCompiler/Bootstrap-1.17/Make, \
		GOROOT_BOOTSTRAP="$(BOOTSTRAP_ROOT_DIR)" \
		$(HOST_GO_VARS) \
	)

	$(call GoCompiler/Bootstrap-1.20/Make, \
		GOROOT_BOOTSTRAP="$(BOOTSTRAP_1_17_BUILD_DIR)" \
		$(HOST_GO_VARS) \
	)

	$(call GoCompiler/Host/Make, \
		GOROOT_BOOTSTRAP="$(BOOTSTRAP_1_20_BUILD_DIR)" \
		$(if $(HOST_GO_ENABLE_PIE),GO_LDFLAGS="-buildmode pie") \
		$(HOST_GO_VARS) \
	)
endef

# If host and target OS/arch are the same, # when go compiles a program, it will
# use the host std lib, so remove it now and force go to rebuild std for target
# later
define Host/Install
	$(call Host/Uninstall)

	$(call GoCompiler/Host/Install/Bin)
	$(call GoCompiler/Host/Install/Src)

	rm -rf "$(HOST_GO_ROOT)/pkg/$(GO_HOST_OS_ARCH)"

	$(INSTALL_DIR) "$(STAGING_DIR_HOSTPKG)/bin"
	$(INSTALL_BIN) ../go-strip-helper "$(STAGING_DIR_HOSTPKG)/bin"

	$(INSTALL_DIR) "$(HOST_GO_ROOT)/openwrt"
	$(INSTALL_BIN) ../go-gcc-helper "$(HOST_GO_ROOT)/openwrt"
	$(LN) go-gcc-helper "$(HOST_GO_ROOT)/openwrt/gcc"
	$(LN) go-gcc-helper "$(HOST_GO_ROOT)/openwrt/g++"
endef

define Host/Uninstall
	rm -f "$(STAGING_DIR_HOSTPKG)/bin/go-strip-helper"
	rm -rf "$(HOST_GO_ROOT)/openwrt"

	$(call GoCompiler/Host/Uninstall)
endef

# Skip downloading and building final bootstrap when building is not configured
ifeq ($(CONFIG_GOLANG_BUILD_BOOTSTRAP),y)
  $(eval $(call HostBuild))
else
  host-compile:
endif

$(eval $(call BuildPackage,golang-bootstrap))
