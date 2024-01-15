#
# Copyright (C) 2019 Jakub Piotr Cłapa <jpc@loee.pl>
# Copyright (C) 2020 Alexandru Ardelean <ardeleanalex@gmail.com>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=numpy
PKG_VERSION:=1.26.3
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=697df43e2b6310ecc9d95f05d5ef20eacc09c7c4ecc9da3f235d39e71b7da1e4

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.txt
PKG_CPE_ID:=cpe:/a:numpy:numpy

PKG_CONFIG_DEPENDS:= \
        CONFIG_NUMPY_OPENBLAS_SUPPORT

PKG_BUILD_DEPENDS:=python-cython/host pyproject-metadata/host

# Ensure numpy does not find openblas if openblas support is not enabled
PYTHON3_PKG_BUILD_VARS:= \
        $(if $(CONFIG_NUMPY_OPENBLAS_SUPPORT),,NPY_BLAS_ORDER= NPY_LAPACK_ORDER= )

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-numpy
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=The fundamental package for scientific computing with Python
  URL:=https://www.numpy.org/
  DEPENDS:=@!SOFT_FLOAT +INSTALL_GFORTRAN:libgfortran +python3 +libstdcpp \
	   +NUMPY_OPENBLAS_SUPPORT:openblas
endef

# We need to duplicate the omitted arhitectures same as openblas
define Package/python3-numpy/config
menu "Configuration"
depends on !powerpc
depends on !arc

config NUMPY_OPENBLAS_SUPPORT
        bool "Enable OpenBLAS support"
        default n

endmenu
endef

ifeq ($(ARCH),x86_64)
# FIXME: temporary fix for x86_64 with GCC 13 + musl;
#        numpy does not detect this compiler extension, so we just enable it
TARGET_CFLAGS += -mavx512f
endif

define Build/Prepare/numpy-sitecfg
	echo "[DEFAULT]"                                 >  $(PKG_BUILD_DIR)/site.cfg
	echo "library_dirs = $(STAGING_DIR)/usr/lib"     >> $(PKG_BUILD_DIR)/site.cfg
	echo "include_dirs = $(STAGING_DIR)/usr/include" >> $(PKG_BUILD_DIR)/site.cfg

  ifdef CONFIG_NUMPY_OPENBLAS_SUPPORT
	echo                                             >> $(PKG_BUILD_DIR)/site.cfg
	echo "[openblas]"                                >> $(PKG_BUILD_DIR)/site.cfg
	echo "libraries = openblas"                      >> $(PKG_BUILD_DIR)/site.cfg
	echo "runtime_library_dirs = /usr/lib"           >> $(PKG_BUILD_DIR)/site.cfg
  endif
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(call Build/Prepare/numpy-sitecfg)
endef

define Package/python3-numpy/description
NumPy is the fundamental package for array computing with Python.

By default, this package is built without some modules.
For some modules to be available, the INSTALL_GFORTRAN symbol needs
to be enabled in the OpenWrt core/toolchain.
endef

$(eval $(call Py3Package,python3-numpy))
$(eval $(call BuildPackage,python3-numpy))
$(eval $(call BuildPackage,python3-numpy-src))
