#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

ifneq ($(__python3_host_mk_inc),1)
__python3_host_mk_inc=1

# For PYTHON3_VERSION
$(call include_mk, python3-version.mk)

HOST_PYTHON3_DIR:=$(STAGING_DIR_HOSTPKG)
HOST_PYTHON3_INC_DIR:=$(HOST_PYTHON3_DIR)/include/python$(PYTHON3_VERSION)
HOST_PYTHON3_LIB_DIR:=$(HOST_PYTHON3_DIR)/lib/python$(PYTHON3_VERSION)

HOST_PYTHON3_PKG_DIR:=$(HOST_PYTHON3_DIR)/lib/python$(PYTHON3_VERSION)/site-packages

HOST_PYTHON3_BIN:=$(HOST_PYTHON3_DIR)/bin/python$(PYTHON3_VERSION)

HOST_PYTHON3PATH:=$(HOST_PYTHON3_LIB_DIR):$(HOST_PYTHON3_PKG_DIR)

define HostPython3
	if [ "$(strip $(3))" == "HOST" ]; then \
		export PYTHONPATH="$(HOST_PYTHON3PATH)"; \
		export PYTHONDONTWRITEBYTECODE=0; \
	else \
		export PYTHONPATH="$(PYTHON3PATH)"; \
		export PYTHONDONTWRITEBYTECODE=1; \
		export _python_sysroot="$(STAGING_DIR)"; \
		export _python_prefix="/usr"; \
		export _python_exec_prefix="/usr"; \
	fi; \
	export PYTHONOPTIMIZE=""; \
	$(1) \
	$(HOST_PYTHON3_BIN) $(2);
endef

# $(1) => commands to execute before running pythons script
# $(2) => python script and its arguments
# $(3) => additional variables
define Build/Compile/HostPy3RunHost
	$(call HostPython3, \
		$(if $(1),$(1);) \
		CC="$(HOSTCC)" \
		CCSHARED="$(HOSTCC) $(HOST_FPIC)" \
		CXX="$(HOSTCXX)" \
		LD="$(HOSTCC)" \
		LDSHARED="$(HOSTCC) -shared" \
		CFLAGS="$(HOST_CFLAGS)" \
		CPPFLAGS="$(HOST_CPPFLAGS) -I$(HOST_PYTHON3_INC_DIR)" \
		LDFLAGS="$(HOST_LDFLAGS) -lpython$(PYTHON3_VERSION) -Wl$(comma)-rpath=$(STAGING_DIR_HOSTPKG)/lib" \
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
define Build/Compile/HostPy3Mod
	$(call Build/Compile/HostPy3RunHost, \
		cd $(HOST_BUILD_DIR)/$(strip $(1)), \
		./setup.py $(2), \
		$(3))
endef

define HostPy3/Compile/Default
	$(call Build/Compile/HostPy3Mod,,\
		install --root="$(STAGING_DIR_HOSTPKG)" --prefix="" \
		--single-version-externally-managed \
	)
endef

ifeq ($(BUILD_VARIANT),python3)
define Host/Compile
	$(call HostPy3/Compile/Default)
endef

define Host/Install
endef
endif # python3

endif # __python3_host_mk_inc
