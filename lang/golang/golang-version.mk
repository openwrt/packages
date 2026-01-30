#
# Copyright (C) 2018-2023, Jeffery To
# Copyright (C) 2025-2026, George Sapkin
#
# SPDX-License-Identifier: GPL-2.0-only

HOST_GO_PREFIX:=$(STAGING_DIR_HOSTPKG)
HOST_GO_VERSION_ID:=$(GO_VERSION_MAJOR_MINOR)
HOST_GO_ROOT:=$(HOST_GO_PREFIX)/lib/go-$(HOST_GO_VERSION_ID)

BOOTSTRAP_DIR:=$(HOST_GO_PREFIX)/lib/go-$(GO_BOOTSTRAP_VERSION)

include ../golang-compiler.mk
include ../golang-package.mk
include ../golang-values.mk

PKG_UNPACK:=$(HOST_TAR) -C "$(PKG_BUILD_DIR)" --strip-components=1 -xzf "$(DL_DIR)/$(PKG_SOURCE)"
HOST_UNPACK:=$(HOST_TAR) -C "$(HOST_BUILD_DIR)" --strip-components=1 -xzf "$(DL_DIR)/$(PKG_SOURCE)"

# don't strip ELF executables in test data
RSTRIP:=:
STRIP:=:

ifeq ($(GO_TARGET_SPECTRE_SUPPORTED),1)
  PKG_CONFIG_DEPENDS+=CONFIG_GOLANG_SPECTRE
endif

define Package/$(PKG_NAME)/Default
  $(call GoPackage/GoSubMenu)
  TITLE:=Go programming language
  URL:=https://go.dev/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/$(PKG_NAME)/Default/description
  The Go programming language is an open source project to make programmers more
  productive.

  Go is expressive, concise, clean, and efficient. Its concurrency mechanisms
  make it easy to write programs that get the most out of multi-core and
  networked machines, while its novel type system enables flexible and modular
  program construction. Go compiles quickly to machine code yet has the
  convenience of garbage collection and the power of run-time reflection. It's
  a fast, statically typed, compiled language that feels like a dynamically
  typed, interpreted language.
endef

ifeq ($(GO_DEFAULT_VERSION),$(GO_VERSION_MAJOR_MINOR))
  ALT_PRIORITY:=500
else
  ALT_PRIORITY:=100
endif

# go tool requires source present:
# https://github.com/golang/go/issues/4635
define Package/$(PKG_NAME)
  $(call Package/$(PKG_NAME)/Default)
  TITLE+= (compiler)
  DEPENDS+= +golang$(GO_VERSION_MAJOR_MINOR)-src
  EXTRA_DEPENDS:=golang$(GO_VERSION_MAJOR_MINOR)-src (=$(PKG_VERSION)-r$(PKG_RELEASE))
  PROVIDES:=@golang
  $(if $(filter $(GO_DEFAULT_VERSION),$(GO_VERSION_MAJOR_MINOR)),DEFAULT_VARIANT:=1)
  ALTERNATIVES:=\
  $(ALT_PRIORITY):/usr/bin/go:/usr/lib/go-$(GO_VERSION_MAJOR_MINOR)/bin/go \
  $(ALT_PRIORITY):/usr/bin/gofmt:/usr/lib/go-$(GO_VERSION_MAJOR_MINOR)/bin/gofmt
endef

define Package/$(PKG_NAME)/description
  $(call Package/$(PKG_NAME)/Default/description)

  This package provides an assembler, compiler, linker, and compiled libraries
  for the Go programming language.
endef

define Package/$(PKG_NAME)/config
  source "$(SOURCE)/../Config.in"
endef

define Package/$(PKG_NAME)-doc
  $(call Package/$(PKG_NAME)/Default)
  TITLE+= (documentation)
  PROVIDES:=@golang-doc
  $(if $(filter $(GO_DEFAULT_VERSION),$(GO_VERSION_MAJOR_MINOR)),DEFAULT_VARIANT:=1)
endef

define Package/$(PKG_NAME)-doc/description
  $(call Package/$(PKG_NAME)/Default/description)

  This package provides the documentation for the Go programming language.
endef

define Package/$(PKG_NAME)-src
  $(call Package/$(PKG_NAME)/Default)
  TITLE+= (source files)
  DEPENDS+= +libstdcpp +libtiff
  PROVIDES:=@golang-src
  $(if $(filter $(GO_DEFAULT_VERSION),$(GO_VERSION_MAJOR_MINOR)),DEFAULT_VARIANT:=1)
endef

define Package/$(PKG_NAME)-src/description
  $(call Package/$(PKG_NAME)/Default/description)

  This package provides the Go programming language source files needed for
  cross-compilation.
endef


# Host

ifeq ($(GO_HOST_PIE_SUPPORTED),1)
  HOST_GO_ENABLE_PIE:=1
endif

# When using GO_LDFLAGS to set buildmode=pie, the PIE install suffix does not
# apply (we also delete the std lib during Host/Install)

$(eval $(call GoCompiler/AddProfile,$(HOST_GO_PROFILE_ID),$(HOST_BUILD_DIR),$(HOST_GO_PREFIX),$(HOST_GO_VERSION_ID),$(GO_HOST_OS_ARCH)))

HOST_GO_VARS?= \
	GOHOSTARCH="$(GO_HOST_ARCH)" \
	GOCACHE="$(GO_BUILD_CACHE_DIR)" \
	GOENV=off \
	CC="$(HOSTCC_NOCACHE)" \
	CXX="$(HOSTCXX_NOCACHE)"

define Host/Configure
	$(call GoCompiler/$(HOST_GO_PROFILE_ID)/CheckHost,$(HOST_GO_VALID_OS_ARCH))

	mkdir -p "$(GO_BUILD_CACHE_DIR)"
endef

define Host/Compile
	$(call GoCompiler/$(HOST_GO_PROFILE_ID)/Make, \
		GOROOT_BOOTSTRAP="$(BOOTSTRAP_DIR)" \
		$(if $(HOST_GO_ENABLE_PIE),GO_LDFLAGS="-buildmode pie") \
		$(HOST_GO_VARS) \
	)
endef

# If host and target OS/arch are the same, when go compiles a program, it will
# use the host std lib, so remove it now and force go to rebuild std for target
# later
define Host/Install
	$(call Host/Uninstall)

	$(call GoCompiler/$(HOST_GO_PROFILE_ID)/Install/Bin)
	$(call GoCompiler/$(HOST_GO_PROFILE_ID)/Install/Src)
	$(call GoCompiler/$(HOST_GO_PROFILE_ID)/Install/BinLinks)

	rm -rf "$(HOST_GO_ROOT)/pkg/$(GO_HOST_OS_ARCH)"

	$(INSTALL_DIR) "$(HOST_GO_ROOT)/openwrt"
	$(INSTALL_BIN) ../go-gcc-helper "$(HOST_GO_ROOT)/openwrt/"
	$(LN) go-gcc-helper "$(HOST_GO_ROOT)/openwrt/gcc"
	$(LN) go-gcc-helper "$(HOST_GO_ROOT)/openwrt/g++"
endef

define Host/Uninstall
	rm -rf "$(HOST_GO_ROOT)/openwrt"

	$(call GoCompiler/$(HOST_GO_PROFILE_ID)/Uninstall/BinLinks)
	$(call GoCompiler/$(HOST_GO_PROFILE_ID)/Uninstall)
endef


# Target

ifeq ($(GO_PKG_ENABLE_PIE),1)
  PKG_GO_INSTALL_SUFFIX:=$(GO_TARGET_PIE_INSTALL_SUFFIX)
endif

$(eval $(call GoCompiler/AddProfile,Package,$(PKG_BUILD_DIR),$(PKG_GO_PREFIX),$(PKG_GO_VERSION_ID),$(GO_OS_ARCH),$(PKG_GO_INSTALL_SUFFIX)))

PKG_GO_ZBOOTSTRAP_MODS?= \
	s/defaultGO386 = `[^`]*`/defaultGO386 = `$(or $(GO_386),sse2)`/; \
	s/defaultGOAMD64 = `[^`]*`/defaultGOAMD64 = `$(or $(GO_AMD64),v1)`/; \
	s/defaultGOARM = `[^`]*`/defaultGOARM = `$(or $(GO_ARM),7)`/; \
	s/defaultGOARM64 = `[^`]*`/defaultGOARM64 = `$(or $(GO_ARM64),v8.0)`/; \
	s/defaultGOMIPS = `[^`]*`/defaultGOMIPS = `$(or $(GO_MIPS),hardfloat)`/; \
	s/defaultGOMIPS64 = `[^`]*`/defaultGOMIPS64 = `$(or $(GO_MIPS64),hardfloat)`/; \
	s/defaultGOPPC64 = `[^`]*`/defaultGOPPC64 = `$(or $(GO_PPC64),power8)`/;

PKG_GO_ZBOOTSTRAP_PATH:=$(PKG_BUILD_DIR)/src/internal/buildcfg/zbootstrap.go

PKG_GO_VARS?= \
	GOHOSTARCH="$(GO_HOST_ARCH)" \
	GOCACHE="$(GO_BUILD_CACHE_DIR)" \
	GOENV=off \
	GO_GCC_HELPER_PATH="$$$$PATH" \
	CC=gcc \
	CXX=g++ \
	PKG_CONFIG=pkg-config \
	PATH="$(HOST_GO_ROOT)/openwrt:$$$$PATH"

PKG_GO_GCFLAGS?= \
	$(if $(GO_PKG_ENABLE_SPECTRE),-spectre all)

PKG_GO_ASMFLAGS?= \
	$(if $(GO_PKG_ENABLE_SPECTRE),-spectre all)

PKG_GO_LDFLAGS?= \
	-buildid '$(SOURCE_DATE_EPOCH)' \
	-linkmode external \
	-extldflags '$(patsubst -z%,-Wl$(comma)-z$(comma)%,$(TARGET_LDFLAGS))' \
	$(if $(CONFIG_NO_STRIP)$(CONFIG_DEBUG),,-s -w)

PKG_GO_INSTALL_ARGS?= \
	-buildvcs=false \
	-trimpath \
	-ldflags "all=$(PKG_GO_LDFLAGS)" \
	$(if $(PKG_GO_GCFLAGS),-gcflags "all=$(PKG_GO_GCFLAGS)") \
	$(if $(PKG_GO_ASMFLAGS),-asmflags "all=$(PKG_GO_ASMFLAGS)") \
	$(if $(filter $(GO_PKG_ENABLE_PIE),1),-buildmode pie)

define Build/Configure
	mkdir -p "$(GO_BUILD_CACHE_DIR)"
endef

define Build/Compile
	@echo "Building target Go first stage"

	$(call GoCompiler/Package/Make, \
		GOROOT_BOOTSTRAP="$(HOST_GO_ROOT)" \
		GO_GCC_HELPER_CC="$(HOSTCC)" \
		GO_GCC_HELPER_CXX="$(HOSTCXX)" \
		$(PKG_GO_VARS) \
	)

	$(SED) '$(PKG_GO_ZBOOTSTRAP_MODS)' "$(PKG_GO_ZBOOTSTRAP_PATH)"

	@echo "Building target Go second stage"

	cd "$(PKG_BUILD_DIR)/bin" ; \
	export $(GO_PKG_TARGET_VARS) ; \
	$(CP) go go-host ; \
	GO_GCC_HELPER_CC="$(TARGET_CC)" \
	GO_GCC_HELPER_CXX="$(TARGET_CXX)" \
	$(PKG_GO_VARS) \
	./go-host install -a $(PKG_GO_INSTALL_ARGS) std cmd; \
	retval=$$$$? ; \
	rm -f go-host ; \
	exit $$$$retval
endef

define Package/$(PKG_NAME)/install
	$(call GoCompiler/Package/Install/Bin,$(1)$(PKG_GO_PREFIX))
endef

define Package/$(PKG_NAME)-doc/install
	$(call GoCompiler/Package/Install/Doc,$(1)$(PKG_GO_PREFIX))
endef

define Package/$(PKG_NAME)-src/install
	$(call GoCompiler/Package/Install/Src,$(1)$(PKG_GO_PREFIX))
endef

# src/debug contains ELF executables as test data and they reference these
# libraries we need to call this in Package/$(GO_VERSION_MAJOR_MINOR)/extra_provides to pass
# CheckDependencies in package-pack.mk
define Package/$(PKG_NAME)-src/extra_provides
	echo 'libc.so.6'
endef
