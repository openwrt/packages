#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

HOST_PYTHON_INC_DIR:=$(STAGING_DIR_HOST)/include/python$(PYTHON_VERSION)

HOST_PYTHON_PKG_DIR:=/lib/python$(PYTHON_VERSION)/site-packages

HOST_PYTHONPATH:=$(HOST_PYTHON_LIB_DIR):$(STAGING_DIR_HOST)/$(HOST_PYTHON_PKG_DIR)
define HostHostPython
	(	export PYTHONPATH="$(HOST_PYTHONPATH)"; \
		export PYTHONOPTIMIZE=""; \
		export PYTHONDONTWRITEBYTECODE=1; \
		export _python_sysroot="$(STAGING_DIR_HOST)"; \
		export _python_prefix=""; \
		export _python_exec_prefix=""; \
		$(1) \
		$(HOST_PYTHON_BIN) $(2); \
	)
endef

# These configure args are needed in detection of path to Python header files
# using autotools.
HOST_CONFIGURE_ARGS += \
	_python_sysroot="$(STAGING_DIR_HOST)" \
	_python_prefix="" \
	_python_exec_prefix=""

# $(1) => build subdir
# $(2) => additional arguments to setup.py
# $(3) => additional variables
define Build/Compile/HostPyMod
	$(call HostHostPython, \
		cd $(HOST_BUILD_DIR)/$(strip $(1)); \
		CC="$(HOSTCC)" \
		CCSHARED="$(HOSTCC) $(HOST_FPIC)" \
		CXX="$(HOSTCXX)" \
		LD="$(HOSTCC)" \
		LDSHARED="$(HOSTCC) -shared" \
		CFLAGS="$(HOST_CFLAGS)" \
		CPPFLAGS="$(HOST_CPPFLAGS) -I$(HOST_PYTHON_INC_DIR)" \
		LDFLAGS="$(HOST_LDFLAGS) -lpython$(PYTHON_VERSION)" \
		_PYTHON_HOST_PLATFORM=linux2 \
		__PYVENV_LAUNCHER__="/usr/bin/$(PYTHON)" \
		$(3) \
		, \
		./setup.py $(2) \
	)
endef

