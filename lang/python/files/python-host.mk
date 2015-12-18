#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

HOST_PYTHON_INC_DIR:=$(STAGING_DIR_HOST)/include/python$(PYTHON_VERSION)

HOST_PYTHON_PKG_DIR:=/usr/lib/python$(PYTHON_VERSION)/site-packages

HOST_PYTHONPATH:=$(HOST_PYTHON_LIB_DIR):$(STAGING_DIR_HOST)/$(HOST_PYTHON_PKG_DIR)
define HostPython
	if [ "$(strip $(3))" == "HOST" ]; then \
		export PYTHONPATH="$(HOST_PYTHONPATH)"; \
		export _python_sysroot="$(STAGING_DIR_HOST)/usr"; \
	else \
		export PYTHONPATH="$(PYTHONPATH)"; \
		export _python_sysroot="$(STAGING_DIR)/usr"; \
	fi; \
	export PYTHONOPTIMIZE=""; \
	export PYTHONDONTWRITEBYTECODE=1; \
	export _python_prefix="/usr"; \
	export _python_exec_prefix="/usr"; \
	$(1) \
	$(HOST_PYTHON_BIN) $(2);
endef

# These configure args are needed in detection of path to Python header files
# using autotools.
HOST_CONFIGURE_ARGS += \
	_python_sysroot="$(STAGING_DIR_HOST)/usr" \
	_python_prefix="/usr" \
	_python_exec_prefix="/usr"

# $(1) => build subdir
# $(2) => additional arguments to setup.py
# $(3) => additional variables
define Build/Compile/HostPyMod
	$(call HostPython, \
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
		, \
		HOST \
	)
endef

