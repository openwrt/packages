#
# Copyright (C) 2018 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

ifeq ($(origin GO_INCLUDE_DIR),undefined)
  GO_INCLUDE_DIR:=$(dir $(lastword $(MAKEFILE_LIST)))
endif

include $(GO_INCLUDE_DIR)/golang-version.mk


unexport \
  GOARCH GOBIN GOCACHE GOFLAGS GOHOSTARCH GOOS GOPATH GORACE GOROOT GOTMPDIR GCCGO \
  GOGC GODEBUG GOMAXPROCS GOTRACEBACK \
  CGO_ENABLED \
  CGO_CFLAGS CGO_CFLAGS_ALLOW CGO_CFLAGS_DISALLOW \
  CGO_CPPFLAGS CGO_CPPFLAGS_ALLOW CGO_CPPFLAGS_DISALLOW \
  CGO_CXXFLAGS CGO_CXXFLAGS_ALLOW CGO_CXXFLAGS_DISALLOW \
  CGO_FFLAGS CGO_FFLAGS_ALLOW CGO_FFLAGS_DISALLOW \
  CGO_LDFLAGS CGO_LDFLAGS_ALLOW CGO_LDFLAGS_DISALLOW \
  GOARM GO386 GOMIPS GOMIPS64 \
  GO111MODULE \
  GOROOT_FINAL GO_EXTLINK_ENABLED GIT_ALLOW_PROTOCOL \
  CC_FOR_TARGET CXX_FOR_TARGET GO_DISTFLAGS GO_GCFLAGS GO_LDFLAGS GOBUILDTIMELOGFILE GOROOT_BOOTSTRAP \
  BOOT_GO_GCFLAGS GOEXPERIMENT GOBOOTSTRAP_TOOLEXEC
  # there are more magic environment variables to track down, but ain't nobody got time for that
  # deliberately left untouched: GOPROXY GONOPROXY GOSUMDB GONOSUMDB GOPRIVATE

go_arch=$(subst \
  aarch64,arm64,$(subst \
  i386,386,$(subst \
  mipsel,mipsle,$(subst \
  mips64el,mips64le,$(subst \
  powerpc64,ppc64,$(subst \
  x86_64,amd64,$(1)))))))

GO_OS:=linux
GO_ARCH:=$(call go_arch,$(ARCH))
GO_OS_ARCH:=$(GO_OS)_$(GO_ARCH)

GO_HOST_OS:=$(call tolower,$(HOST_OS))
GO_HOST_ARCH:=$(call go_arch,$(subst \
  armv6l,arm,$(subst \
  armv7l,arm,$(subst \
  i486,i386,$(subst \
  i586,i386,$(subst \
  i686,i386,$(HOST_ARCH)))))))
GO_HOST_OS_ARCH:=$(GO_HOST_OS)_$(GO_HOST_ARCH)

GO_HOST_TARGET_SAME:=$(if $(and $(findstring $(GO_OS_ARCH),$(GO_HOST_OS_ARCH)),$(findstring $(GO_HOST_OS_ARCH),$(GO_OS_ARCH))),1)
GO_HOST_TARGET_DIFFERENT:=$(if $(GO_HOST_TARGET_SAME),,1)

# ensure binaries can run on older CPUs
GO_386:=387

ifeq ($(GO_ARCH),arm)
  GO_TARGET_FPU:=$(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE))))

  # FPU names from https://gcc.gnu.org/onlinedocs/gcc-8.3.0/gcc/ARM-Options.html#index-mfpu-1
  # see also https://github.com/gcc-mirror/gcc/blob/gcc-8_3_0-release/gcc/config/arm/arm-cpus.in
  #
  # Assumptions:
  #
  # * -d16 variants (16 instead of 32 double-precision registers) acceptable
  #   Go doesn't appear to check the HWCAP_VFPv3D16 flag in
  #   https://github.com/golang/go/blob/release-branch.go1.13/src/runtime/os_linux_arm.go
  #
  # * Double-precision required
  #   Based on no evidence(!)
  #   Excludes vfpv3xd, vfpv3xd-fp16, fpv4-sp-d16, fpv5-sp-d16

  GO_ARM_7_FPUS:= \
    vfpv3 vfpv3-fp16 vfpv3-d16 vfpv3-d16-fp16 neon neon-vfpv3 neon-fp16 \
    vfpv4 vfpv4-d16 neon-vfpv4 \
    fpv5-d16 fp-armv8 neon-fp-armv8 crypto-neon-fp-armv8

  GO_ARM_6_FPUS:=vfp vfpv2

  ifneq ($(filter $(GO_TARGET_FPU),$(GO_ARM_7_FPUS)),)
    GO_ARM:=7
  else ifneq ($(filter $(GO_TARGET_FPU),$(GO_ARM_6_FPUS)),)
    GO_ARM:=6
  else
    GO_ARM:=5
  endif
endif

GO_MIPS:=$(if $(filter $(GO_ARCH),mips mipsle),$(if $(CONFIG_HAS_FPU),hardfloat,softfloat),)

GO_MIPS64:=$(if $(filter $(GO_ARCH),mips64 mips64le),$(if $(CONFIG_HAS_FPU),hardfloat,softfloat),)

# -fno-plt: causes "unexpected GOT reloc for non-dynamic symbol" errors
# -mips32r2: conflicts with -march=mips32 set by go
GO_CFLAGS_TO_REMOVE:=$(if \
$(filter $(GO_ARCH),386),-fno-plt,$(if \
$(filter $(GO_ARCH),mips mipsle),-mips32r2,))

GO_ARCH_DEPENDS:=@(aarch64||arm||i386||i686||mips||mips64||mips64el||mipsel||powerpc64||x86_64)

GO_TARGET_PREFIX:=/usr
GO_TARGET_VERSION_ID:=$(GO_VERSION_MAJOR_MINOR)
GO_TARGET_ROOT:=$(GO_TARGET_PREFIX)/lib/go-$(GO_TARGET_VERSION_ID)
