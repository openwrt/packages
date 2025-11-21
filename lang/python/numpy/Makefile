#
# Copyright (C) 2019 Jakub Piotr Cłapa <jpc@loee.pl>
# Copyright (C) 2020 Alexandru Ardelean <ardeleanalex@gmail.com>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=numpy
PKG_VERSION:=2.3.4
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=a7d018bfedb375a8d979ac758b120ba846a7fe764911a64465fd87b8729f4a6a

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

MESON_USE_STAGING_PYTHON:=1

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk
include $(INCLUDE_DIR)/meson.mk

MESON_ARGS+= \
	-Ddisable-optimization=true \
	-Dcpu-baseline=min

# FIXME: remove asap; added in 2.2.5
TARGET_CFLAGS += \
	-Wno-error=incompatible-pointer-types

# Override 'Meson', to use numpy's vendored meson
define Meson
	$(call Python3/Run,,$(PKG_BUILD_DIR)/vendored-meson/meson/meson.py $(1),$(2))
endef

define Meson/CreateCrossFile
	$(STAGING_DIR_HOST)/bin/sed \
		-e "s|@CC@|$(foreach BIN,$(TARGET_CC),'$(BIN)',)|" \
		-e "s|@CXX@|$(foreach BIN,$(TARGET_CXX),'$(BIN)',)|" \
		-e "s|@LD@|$(foreach FLAG,$(TARGET_LINKER),'$(FLAG)',)|" \
		-e "s|@AR@|$(TARGET_AR)|" \
		-e "s|@STRIP@|$(TARGET_CROSS)strip|" \
		-e "s|@NM@|$(TARGET_NM)|" \
		-e "s|@PKGCONFIG@|$(PKG_CONFIG)|" \
		-e "s|@CMAKE@|$(STAGING_DIR_HOST)/bin/cmake|" \
		-e "s|@PYTHON@|$(PYTHON_BIN)|" \
		-e "s|@CFLAGS@|$(foreach FLAG,$(TARGET_CFLAGS) $(EXTRA_CFLAGS) $(TARGET_CPPFLAGS) $(EXTRA_CPPFLAGS),'$(FLAG)',)|" \
		-e "s|@CXXFLAGS@|$(foreach FLAG,$(TARGET_CXXFLAGS) $(EXTRA_CXXFLAGS) $(TARGET_CPPFLAGS) $(EXTRA_CPPFLAGS),'$(FLAG)',)|" \
		-e "s|@LDFLAGS@|$(foreach FLAG,$(TARGET_LDFLAGS) $(EXTRA_LDFLAGS),'$(FLAG)',)|" \
		-e "s|@ARCH@|$(MESON_ARCH)|" \
		-e "s|@CPU@|$(MESON_CPU)|" \
		-e "s|@ENDIAN@|$(if $(CONFIG_BIG_ENDIAN),big,little)|" \
		< files/openwrt-cross.txt.in \
		> $(1)
	echo "longdouble_format = '$(if $(CONFIG_BIG_ENDIAN),IEEE_DOUBLE_BE,IEEE_DOUBLE_LE)'" >> $(1)
endef

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
