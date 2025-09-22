#
# Copyright (C) 2021 Alexandru Ardelean <ardeleanalex@gmail.com>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=OpenBLAS
PKG_VERSION:=0.3.30
PKG_RELEASE:=2

PKG_SOURCE:=OpenBLAS-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/OpenMathLib/OpenBLAS/releases/download/v$(PKG_VERSION)/
PKG_HASH:=27342cff518646afb4c2b976d809102e368957974c250a25ccc965e53063c95d
PKG_LICENSE:=BSD-3-Clause
PKG_CPE_ID:=cpe:/a:openblas_project:openblas
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/openblas
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=An optimized library for BLAS (Basic Linear Algebra Subprograms)
  URL:=https://www.openblas.net/
  DEPENDS:= \
       @!arc \
       @!powerpc \
       @!SOFT_FLOAT \
       +INSTALL_GFORTRAN:libgfortran
endef

define Package/openblas/description
  OpenBLAS is an optimized BLAS (Basic Linear Algebra Subprograms) library
  based on GotoBLAS2 1.13 BSD version.
endef

define Package/openblas/config
menu "Configuration"
depends on PACKAGE_openblas

config OPENBLAS_TARGET_OVERRIDE
	string
	prompt "Manual CPU target override (from the OpenBLAS TargetList.txt file)"

endmenu
endef

OPENBLAS_TARGET=$(call qstrip,$(CONFIG_OPENBLAS_TARGET_OVERRIDE))

ifeq ($(OPENBLAS_TARGET),)
# initialize to GENERIC as default
OPENBLAS_TARGET:=GENERIC

ifneq ($(findstring cortex-a9,$(CONFIG_CPU_TYPE)),)
	ifneq ($(findstring neon,$(CONFIG_CPU_TYPE)),)
		# CORTEXA9 relies on NEON
		OPENBLAS_TARGET:=CORTEXA9
	else
		# Fallback for CPUs without NEON
		OPENBLAS_TARGET:=ARMV7
	endif
else ifneq ($(findstring cortex-a15,$(CONFIG_CPU_TYPE)),)
	OPENBLAS_TARGET:=CORTEXA15
else ifneq ($(findstring cortex-a53,$(CONFIG_CPU_TYPE)),)
	OPENBLAS_TARGET:=CORTEXA53
else ifneq ($(findstring cortex-a72,$(CONFIG_CPU_TYPE)),)
	OPENBLAS_TARGET:=CORTEXA72
else ifeq ($(ARCH),aarch64)
  OPENBLAS_TARGET:=ARMV8
else ifeq ($(ARCH),arm)
  OPENBLAS_TARGET:=ARMV5
else ifeq ($(ARCH),mips)
  OPENBLAS_TARGET:=MIPS24K
else ifeq ($(ARCH),mipsel)
  OPENBLAS_TARGET:=MIPS24K
else ifeq ($(ARCH),powerpc)
  OPENBLAS_TARGET:=PPC440
else ifeq ($(ARCH),riscv64)
  OPENBLAS_TARGET:=RISCV64_GENERIC
endif
endif # ifeq ($(OPENBLAS_TARGET),)

ifeq ($(CONFIG_ARCH_64BIT),y)
OPENBLAS_BINARY:=64
else
OPENBLAS_BINARY:=32
endif

MAKE_FLAGS += \
	CROSS=1 \
	CC=$(TARGET_CC_NOCACHE) \
	CXX=$(TARGET_CXX_NOCACHE) \
	HOSTCC=$(HOSTCC_NOCACHE) \
	CROSS_SUFFIX=$(TARGET_CROSS) \
	BINARY=$(OPENBLAS_BINARY) \
	MAKE_NB_JOBS=-1 \
	NUM_THREADS=2 \
	PREFIX=/usr \
	COMMON_OPT="" \
	ONLY_CBLAS=1 \
	TARGET=$(call qstrip,$(OPENBLAS_TARGET))

ifneq ($(CONFIG_INSTALL_GFORTRAN),y)
MAKE_FLAGS += NOFORTRAN=1
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/openblas.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/openblas.pc
endef

define Package/openblas/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopenblas*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,openblas))
