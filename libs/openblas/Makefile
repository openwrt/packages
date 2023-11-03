#
# Copyright (C) 2021 Alexandru Ardelean <ardeleanalex@gmail.com>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=OpenBLAS
PKG_VERSION:=0.3.24
PKG_RELEASE:=1

PKG_SOURCE:=OpenBLAS-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/xianyi/OpenBLAS/releases/download/v$(PKG_VERSION)/
PKG_HASH:=ceadc5065da97bd92404cac7254da66cc6eb192679cf1002098688978d4d5132
PKG_LICENSE:=BSD 3-Clause
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
CPU_TYPE=$(call qstrip,$(CONFIG_CPU_TYPE))

ifeq ($(OPENBLAS_TARGET),)
# initialize to GENERIC as default
OPENBLAS_TARGET:=GENERIC

ifeq ($(ARCH),aarch64)
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
endef

define Package/openblas/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopenblas*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,openblas))
