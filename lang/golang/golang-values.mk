#
# Copyright (C) 2018-2023 Jeffery To
# Copyright (C) 2025-2026 George Sapkin
#
# SPDX-License-Identifier: GPL-2.0-only

ifeq ($(origin GO_INCLUDE_DIR),undefined)
  GO_INCLUDE_DIR:=$(dir $(lastword $(MAKEFILE_LIST)))
endif


# Unset environment variables
# There are more magic variables to track down, but ain't nobody got time for that

# From https://pkg.go.dev/cmd/go#hdr-Environment_variables

# General-purpose environment variables:
unexport \
  GO111MODULE \
  GCCGO \
  GOARCH \
  GOBIN \
  GOCACHE \
  GOMODCACHE \
  GODEBUG \
  GOENV \
  GOFLAGS \
  GOOS \
  GOPATH \
  GOROOT \
  GOTOOLCHAIN \
  GOTMPDIR \
  GOWORK
# Unmodified:
#   GOINSECURE
#   GOPRIVATE
#   GOPROXY
#   GONOPROXY
#   GOSUMDB
#   GONOSUMDB
#   GOVCS

# Environment variables for use with cgo:
unexport \
  AR \
  CC \
  CGO_ENABLED \
  CGO_CFLAGS   CGO_CFLAGS_ALLOW   CGO_CFLAGS_DISALLOW \
  CGO_CPPFLAGS CGO_CPPFLAGS_ALLOW CGO_CPPFLAGS_DISALLOW \
  CGO_CXXFLAGS CGO_CXXFLAGS_ALLOW CGO_CXXFLAGS_DISALLOW \
  CGO_FFLAGS   CGO_FFLAGS_ALLOW   CGO_FFLAGS_DISALLOW \
  CGO_LDFLAGS  CGO_LDFLAGS_ALLOW  CGO_LDFLAGS_DISALLOW \
  CXX \
  FC
# Unmodified:
#   PKG_CONFIG

# Architecture-specific environment variables:
unexport \
  GOARM \
  GOARM64 \
  GO386 \
  GOAMD64 \
  GOMIPS \
  GOMIPS64 \
  GOPPC64 \
  GORISCV64 \
  GOWASM

# Environment variables for use with code coverage:
unexport \
  GOCOVERDIR

# Special-purpose environment variables:
unexport \
  GCCGOTOOLDIR \
  GOEXPERIMENT \
  GOROOT_FINAL \
  GO_EXTLINK_ENABLED
# Unmodified:
#   GIT_ALLOW_PROTOCOL

# From https://pkg.go.dev/runtime#hdr-Environment_Variables
unexport \
  GOGC \
  GOMEMLIMIT \
  GOMAXPROCS \
  GORACE \
  GOTRACEBACK

# From https://pkg.go.dev/cmd/cgo#hdr-Using_cgo_with_the_go_command
unexport \
  CC_FOR_TARGET \
  CXX_FOR_TARGET
# Todo:
#   CC_FOR_${GOOS}_${GOARCH}
#   CXX_FOR_${GOOS}_${GOARCH}

# From https://go.dev/doc/install/source#environment
unexport \
  GOHOSTOS \
  GOHOSTARCH

# From https://go.dev/src/make.bash
unexport \
  GO_GCFLAGS \
  GO_LDFLAGS \
  GO_LDSO \
  GO_DISTFLAGS \
  GOBUILDTIMELOGFILE \
  GOROOT_BOOTSTRAP

# From https://go.dev/doc/go1.9#parallel-compile
unexport \
  GO19CONCURRENTCOMPILATION

# From https://go.dev/src/cmd/dist/build.go
unexport \
  BOOT_GO_GCFLAGS \
  BOOT_GO_LDFLAGS

# From https://go.dev/src/cmd/dist/buildtool.go
unexport \
  GOBOOTSTRAP_TOOLEXEC


GO_DEFAULT_VERSION:=1.25
GO_HOST_VERSION:=$(patsubst golang%/host,%,$(filter golang%/host,$(PKG_BUILD_DEPENDS)))
ifeq ($(GO_HOST_VERSION),)
  GO_HOST_VERSION:=$(GO_DEFAULT_VERSION)
endif

# GOOS / GOARCH

go_arch=$(subst \
  aarch64,arm64,$(subst \
  i386,386,$(subst \
  loongarch64,loong64,$(subst \
  mipsel,mipsle,$(subst \
  mips64el,mips64le,$(subst \
  powerpc64,ppc64,$(subst \
  x86_64,amd64,$(1))))))))

GO_OS:=linux
GO_ARCH:=$(call go_arch,$(ARCH))
GO_OS_ARCH:=$(GO_OS)/$(GO_ARCH)

GO_HOST_OS:=$(call tolower,$(HOST_OS))
GO_HOST_ARCH:=$(call go_arch,$(subst \
  armv6l,arm,$(subst \
  armv7l,arm,$(subst \
  i686,i386,$(HOST_ARCH)))))
GO_HOST_OS_ARCH:=$(GO_HOST_OS)/$(GO_HOST_ARCH)

# Filter lists for ARM64 cores
# See https://en.wikipedia.org/wiki/ARM_architecture_family#Cores
GO_ARM64_V8_0_CORES= \
  cortex-a34 \
  cortex-a35 \
  cortex-a53 \
  cortex-a57 \
  cortex-a72 \
  cortex-a73
GO_ARM64_V8_2_CORES= \
  cortex-a55 \
  cortex-a65 \
  cortex-a75 \
  cortex-a76 \
  cortex-a77 \
  cortex-a78 \
  cortex-x1
GO_ARM64_V9_0_CORES= \
  cortex-a510 \
  cortex-a710 \
  cortex-a715 \
  cortex-x2 \
  cortex-x3
GO_ARM64_V9_2_CORES= \
  cortex-a520 \
  cortex-a720 \
  cortex-x4

ifeq ($(GO_OS_ARCH),$(GO_HOST_OS_ARCH))
  GO_HOST_TARGET_SAME:=1
else
  GO_HOST_TARGET_DIFFERENT:=1
endif

ifeq ($(GO_ARCH),386)
  ifeq ($(CONFIG_TARGET_x86_geode)$(CONFIG_TARGET_x86_legacy),y)
    GO_386:=softfloat
  else
    GO_386:=sse2
  endif

  # -fno-plt: causes "unexpected GOT reloc for non-dynamic symbol" errors
  GO_CFLAGS_TO_REMOVE:=-fno-plt

else ifeq ($(GO_ARCH),amd64)
  GO_AMD64:=v1

else ifeq ($(GO_ARCH),arm)
  GO_TARGET_FPU:=$(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE))))

  # FPU names from https://gcc.gnu.org/onlinedocs/gcc-8.4.0/gcc/ARM-Options.html#index-mfpu-1
  # see also https://github.com/gcc-mirror/gcc/blob/releases/gcc-8.4.0/gcc/config/arm/arm-cpus.in

  ifeq ($(GO_TARGET_FPU),)
    GO_ARM:=5
  else ifneq ($(filter $(GO_TARGET_FPU),vfp vfpv2),)
    GO_ARM:=6
  else
    GO_ARM:=7
  endif

else ifeq ($(GO_ARCH),arm64)
  GO_TARGET_CPU:=$(call qstrip,$(CONFIG_CPU_TYPE))

  ifneq ($(filter $(GO_TARGET_CPU),$(GO_ARM64_V8_0_CORES)),)
    GO_ARM64:=v8.0
  else ifneq ($(filter $(GO_TARGET_CPU),$(GO_ARM64_V8_2_CORES)),)
    GO_ARM64:=v8.2
  else ifneq ($(filter $(GO_TARGET_CPU),$(GO_ARM64_V9_0_CORES)),)
    GO_ARM64:=v9.0
  else ifneq ($(filter $(GO_TARGET_CPU),$(GO_ARM64_V9_2_CORES)),)
    GO_ARM64:=v9.2
  else
    # Unknown CPU, assume baseline
    GO_ARM64:=v8.0
  endif

else ifneq ($(filter $(GO_ARCH),mips mipsle),)
  ifeq ($(CONFIG_HAS_FPU),y)
    GO_MIPS:=hardfloat
  else
    GO_MIPS:=softfloat
  endif

  # -mips32r2: conflicts with -march=mips32 set by go
  GO_CFLAGS_TO_REMOVE:=-mips32r2

else ifneq ($(filter $(GO_ARCH),mips64 mips64le),)
  ifeq ($(CONFIG_HAS_FPU),y)
    GO_MIPS64:=hardfloat
  else
    GO_MIPS64:=softfloat
  endif

else ifeq ($(GO_ARCH),ppc64)
  GO_PPC64:=power8

endif

GO_GENERATED_FILES := \
  src/cmd/cgo/zdefaultcc.go \
  src/cmd/go/internal/cfg/zdefaultcc.go \
  src/cmd/internal/objabi/zbootstrap.go \
  src/go/build/zcgo.go \
  src/internal/buildcfg/zbootstrap.go \
  src/internal/runtime/sys/zversion.go \
  src/time/tzdata/zzipdata.go

GO_LEGAL_FILES := \
  CONTRIBUTING.md \
  LICENSE \
  PATENTS \
  README.md \
  SECURITY.md

GO_BIN_FILES := \
  $(GO_GENERATED_FILES) \
  $(GO_LEGAL_FILES)

GO_HOST_SRC_FILTERS := ! -name '*.bat' -a ! -name '*.rc'
GO_TARGET_SRC_FILTERS := ! -ipath '*/testdata/*' -a ! -name '*_test.go' -a ! -name '*.bat' -a ! -name '*.rc'
GO_TARGET_TEST_FILTERS := -ipath '*/testdata/*' -o -name '*_test.go'


# Target Go

GO_ARCH_DEPENDS:=@(aarch64||arm||i386||i686||loongarch64||mips||mips64||mips64el||mipsel||riscv64||x86_64)


# ASLR/PIE

# From https://go.dev/src/internal/platform/supported.go
GO_PIE_SUPPORTED_OS_ARCH:= \
  aix/ppc64 \
  android/386 \
  android/amd64 \
  android/arm \
  android/arm64 \
  darwin/amd64 \
  darwin/arm64 \
  freebsd/amd64 \
  ios/amd64 \
  ios/arm64 \
  linux/386 \
  linux/amd64 \
  linux/arm \
  linux/arm64 \
  linux/loong64 \
  linux/ppc64le \
  linux/riscv64 \
  linux/s390x \
  openbsd/arm64 \
  windows/386 \
  windows/amd64 \
  windows/arm \
  windows/arm64

# From https://go.dev/src/cmd/go/internal/work/init.go
go_pie_install_suffix=$(if $(filter $(1),aix/ppc64 windows/386 windows/amd64 windows/arm windows/arm64),,shared)

ifneq ($(filter $(GO_HOST_OS_ARCH),$(GO_PIE_SUPPORTED_OS_ARCH)),)
  GO_HOST_PIE_SUPPORTED:=1
  GO_HOST_PIE_INSTALL_SUFFIX:=$(call go_pie_install_suffix,$(GO_HOST_OS_ARCH))
endif

ifneq ($(filter $(GO_OS_ARCH),$(GO_PIE_SUPPORTED_OS_ARCH)),)
  GO_TARGET_PIE_SUPPORTED:=1
  GO_TARGET_PIE_INSTALL_SUFFIX:=$(call go_pie_install_suffix,$(GO_OS_ARCH))
endif


# Spectre mitigations

GO_SPECTRE_SUPPORTED_ARCH:=amd64

ifneq ($(filter $(GO_HOST_ARCH),$(GO_SPECTRE_SUPPORTED_ARCH)),)
  GO_HOST_SPECTRE_SUPPORTED:=1
endif

ifneq ($(filter $(GO_ARCH),$(GO_SPECTRE_SUPPORTED_ARCH)),)
  GO_TARGET_SPECTRE_SUPPORTED:=1
endif


# General build info

GO_BUILD_CACHE_DIR:=$(or $(call qstrip,$(CONFIG_GOLANG_BUILD_CACHE_DIR)),$(TMP_DIR)/go-build)
GO_MOD_CACHE_DIR:=$(DL_DIR)/go-mod-cache

GO_MOD_ARGS= \
	-modcacherw

GO_GENERAL_BUILD_CONFIG_VARS= \
	CONFIG_GOLANG_MOD_CACHE_WORLD_READABLE="$(CONFIG_GOLANG_MOD_CACHE_WORLD_READABLE)" \
	GO_BUILD_CACHE_DIR="$(GO_BUILD_CACHE_DIR)" \
	GO_MOD_CACHE_DIR="$(GO_MOD_CACHE_DIR)" \
	GO_MOD_ARGS="$(GO_MOD_ARGS)"

define Go/CacheCleanup
	$(GO_GENERAL_BUILD_CONFIG_VARS) \
	$(SHELL) $(GO_INCLUDE_DIR)/golang-build.sh cache_cleanup
endef
