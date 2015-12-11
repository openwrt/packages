#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

HOST_PYTHON3_INC_DIR:=$(STAGING_DIR_HOST)/include/python$(PYTHON3_VERSION)

HOST_PYTHON3_PKG_DIR:=/usr/lib/python$(PYTHON3_VERSION)/site-packages

HOST_PYTHON3PATH:=$(HOST_PYTHON3_LIB_DIR):$(STAGING_DIR_HOST)/$(HOST_PYTHON3_PKG_DIR)
define HostPython3
	if [ "($(strip $(3))" == "HOST" ]; then \
		export PYTHONPATH="$(HOST_PYTHON3PATH)"; \
		export _python_sysroot="$(STAGING_DIR_HOST)/usr"; \
	else \
		export PYTHONPATH="$(PYTHON3PATH)"; \
		export _python_sysroot="$(STAGING_DIR)/usr"; \
	fi; \
	export PYTHONOPTIMIZE=""; \
	export PYTHONDONTWRITEBYTECODE=1; \
	export _python_prefix="/usr"; \
	export _python_exec_prefix="/usr"; \
	$(1) \
	$(HOST_PYTHON3_BIN) $(2);
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
define Build/Compile/HostPy3Mod
	$(call HostPython3, \
		cd $(HOST_BUILD_DIR)/$(strip $(1)); \
		CC="$(HOSTCC)" \
		CCSHARED="$(HOSTCC) $(HOST_FPIC)" \
		CXX="$(HOSTCXX)" \
		LD="$(HOSTCC)" \
		LDSHARED="$(HOSTCC) -shared" \
		CFLAGS="$(HOST_CFLAGS)" \
		CPPFLAGS="$(HOST_CPPFLAGS) -I$(HOST_PYTHON3_INC_DIR)" \
		LDFLAGS="$(HOST_LDFLAGS) -lpython$(PYTHON3_VERSION)" \
		_PYTHON_HOST_PLATFORM=linux2 \
		__PYVENV_LAUNCHER__="/usr/bin/$(PYTHON3)" \
		$(3) \
		, \
		./setup.py $(2) \
		, \
		HOST \
	)
endef

