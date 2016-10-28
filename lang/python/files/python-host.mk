#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# For HOST_BUILD_PREFIX
include $(INCLUDE_DIR)/host-build.mk

HOST_PYTHON_DIR:=$(HOST_BUILD_PREFIX)
HOST_PYTHON_INC_DIR:=$(HOST_PYTHON_DIR)/include/python$(PYTHON_VERSION)
HOST_PYTHON_LIB_DIR:=$(HOST_PYTHON_DIR)/lib/python$(PYTHON_VERSION)

HOST_PYTHON_PKG_DIR:=/lib/python$(PYTHON_VERSION)/site-packages

HOST_PYTHON_BIN:=$(HOST_PYTHON_DIR)/bin/python$(PYTHON_VERSION)

HOST_PYTHONPATH:=$(HOST_PYTHON_LIB_DIR):$(HOST_BUILD_PREFIX)/$(HOST_PYTHON_PKG_DIR)

define HostPython
	if [ "$(strip $(3))" == "HOST" ]; then \
		export PYTHONPATH="$(HOST_PYTHONPATH)"; \
		export PYTHONDONTWRITEBYTECODE=0; \
	else \
		export PYTHONPATH="$(PYTHONPATH)"; \
		export PYTHONDONTWRITEBYTECODE=1; \
		export _python_sysroot="$(STAGING_DIR)"; \
		export _python_prefix="/usr"; \
		export _python_exec_prefix="/usr"; \
	fi; \
	export PYTHONOPTIMIZE=""; \
	$(1) \
	$(HOST_PYTHON_BIN) $(2);
endef

# $(1) => commands to execute before running pythons script
# $(2) => python script and its arguments
# $(3) => additional variables
define Build/Compile/HostPyRunHost
	$(call HostPython, \
		$(if $(1),$(1);) \
		CC="$(HOSTCC)" \
		CCSHARED="$(HOSTCC) $(HOST_FPIC)" \
		CXX="$(HOSTCXX)" \
		LD="$(HOSTCC)" \
		LDSHARED="$(HOSTCC) -shared" \
		CFLAGS="$(HOST_CFLAGS)" \
		CPPFLAGS="$(HOST_CPPFLAGS) -I$(HOST_PYTHON_INC_DIR)" \
		LDFLAGS="$(HOST_LDFLAGS) -lpython$(PYTHON_VERSION) -Wl$(comma)-rpath=$(HOST_BUILD_PREFIX)/lib" \
		_PYTHON_HOST_PLATFORM=linux2 \
		$(3) \
		, \
		$(2) \
		, \
		HOST \
	)
endef


# $(1) => build subdir
# $(2) => additional arguments to setup.py
# $(3) => additional variables
define Build/Compile/HostPyMod
	$(call Build/Compile/HostPyRunHost, \
		cd $(HOST_BUILD_DIR)/$(strip $(1)), \
		./setup.py $(2), \
		$(3))
endef

