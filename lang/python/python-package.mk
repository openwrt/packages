#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# Note: include this after `include $(TOPDIR)/rules.mk in your package Makefile

python_mk_path:=$(dir $(lastword $(MAKEFILE_LIST)))
include $(python_mk_path)python-host.mk

PYTHON_DIR:=$(STAGING_DIR)/usr
PYTHON_BIN_DIR:=$(PYTHON_DIR)/bin
PYTHON_INC_DIR:=$(PYTHON_DIR)/include/python$(PYTHON_VERSION)
PYTHON_LIB_DIR:=$(PYTHON_DIR)/lib/python$(PYTHON_VERSION)

PYTHON_PKG_DIR:=/usr/lib/python$(PYTHON_VERSION)/site-packages

PYTHON:=python$(PYTHON_VERSION)

PYTHONPATH:=$(PYTHON_LIB_DIR):$(STAGING_DIR)/$(PYTHON_PKG_DIR):$(PKG_INSTALL_DIR)/$(PYTHON_PKG_DIR)

# These configure args are needed in detection of path to Python header files
# using autotools.
CONFIGURE_ARGS += \
	_python_sysroot="$(STAGING_DIR)" \
	_python_prefix="/usr" \
	_python_exec_prefix="/usr"

PKG_USE_MIPS16:=0
# This is required in addition to PKG_USE_MIPS16:=0 because otherwise MIPS16
# flags are inherited from the Python base package (via sysconfig module)
ifdef CONFIG_USE_MIPS16
  TARGET_CFLAGS += -mno-mips16 -mno-interlink-mips16
endif

define PyPackage

  define Package/$(1)-src
    $(call Package/$(1))
    DEPENDS:=
    CONFLICTS:=
    PROVIDES:=
    EXTRA_DEPENDS:=
    TITLE+= (sources)
    USERID:=
    MENU:=
  endef

  define Package/$(1)-src/description
    $(call Package/$(1)/description).
    (Contains the Python sources for this package).
  endef

  # Add default PyPackage filespec none defined
  ifndef PyPackage/$(1)/filespec
    define PyPackage/$(1)/filespec
      +|$(PYTHON_PKG_DIR)
    endef
  endif

  ifndef PyPackage/$(1)/install
    define PyPackage/$(1)/install
		if [ -d $(PKG_INSTALL_DIR)/usr/bin ]; then \
			$(INSTALL_DIR) $$(1)/usr/bin ; \
			$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $$(1)/usr/bin/ ; \
		fi
    endef
  endif

  ifndef Package/$(1)/install
  $(call shexport,PyPackage/$(1)/filespec)

  define Package/$(1)/install
	$$(call PyPackage/$(1)/install,$$(1))
	SED="$(SED)" \
	$(SHELL) $(python_mk_path)python-package-install.sh "2" \
		"$(PKG_INSTALL_DIR)" "$$(1)" \
		"$(HOST_PYTHON_BIN)" "$$(2)" \
		"$$$$$$$$$$(call shvar,PyPackage/$(1)/filespec)"
  endef

  define Package/$(1)-src/install
	$$(call Package/$(1)/install,$$(1),sources)
  endef
  endif # Package/$(1)/install
endef

# $(1) => commands to execute before running pythons script
# $(2) => python script and its arguments
# $(3) => additional variables
define Build/Compile/HostPyRunTarget
	$(call HostPython, \
		$(if $(1),$(1);) \
		CC="$(TARGET_CC)" \
		CCSHARED="$(TARGET_CC) $(FPIC)" \
		CXX="$(TARGET_CXX)" \
		LD="$(TARGET_CC)" \
		LDSHARED="$(TARGET_CC) -shared" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="$(TARGET_CPPFLAGS) -I$(PYTHON_INC_DIR)" \
		LDFLAGS="$(TARGET_LDFLAGS) -lpython$(PYTHON_VERSION)" \
		_PYTHON_HOST_PLATFORM=linux2 \
		__PYVENV_LAUNCHER__="/usr/bin/$(PYTHON)" \
		$(3) \
		, \
		$(2) \
	)
endef

# $(1) => build subdir
# $(2) => additional arguments to setup.py
# $(3) => additional variables
define Build/Compile/PyMod
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/$(PYTHON_PKG_DIR)
	$(call Build/Compile/HostPyRunTarget, \
		cd $(PKG_BUILD_DIR)/$(strip $(1)), \
		./setup.py $(2), \
		$(3))
endef

PYTHON_PKG_SETUP_DIR ?=
PYTHON_PKG_SETUP_GLOBAL_ARGS ?=
PYTHON_PKG_SETUP_ARGS ?= --single-version-externally-managed
PYTHON_PKG_SETUP_VARS ?=

define PyBuild/Compile/Default
	$(if $(HOST_PYTHON_PACKAGE_BUILD_DEPENDS),
		$(call Build/Compile/HostPyPipInstall,$(HOST_PYTHON_PACKAGE_BUILD_DEPENDS))
	)
	$(call Build/Compile/PyMod, \
		$(PYTHON_PKG_SETUP_DIR), \
		$(PYTHON_PKG_SETUP_GLOBAL_ARGS) \
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)" \
		$(PYTHON_PKG_SETUP_ARGS), \
		$(PYTHON_PKG_SETUP_VARS) \
	)
endef

PyBuild/Compile=$(PyBuild/Compile/Default)

ifeq ($(BUILD_VARIANT),python)
define Build/Compile
	$(call PyBuild/Compile)
endef
endif # python
