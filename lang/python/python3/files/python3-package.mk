#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

$(call include_mk, python3-version.mk)

PYTHON3_DIR:=$(STAGING_DIR)/usr
PYTHON3_BIN_DIR:=$(PYTHON3_DIR)/bin
PYTHON3_INC_DIR:=$(PYTHON3_DIR)/include/python$(PYTHON3_VERSION)
PYTHON3_LIB_DIR:=$(PYTHON3_DIR)/lib/python$(PYTHON3_VERSION)

PYTHON3_PKG_DIR:=/usr/lib/python$(PYTHON3_VERSION)/site-packages

PYTHON3:=python$(PYTHON3_VERSION)

PYTHON3PATH:=$(PYTHON3_LIB_DIR):$(STAGING_DIR)/$(PYTHON3_PKG_DIR):$(PKG_INSTALL_DIR)/$(PYTHON3_PKG_DIR)

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

define Py3Package

  define Package/$(1)-src
    $(call Package/$(1))
    TITLE+= (sources)
    DEPENDS:=$$$$(foreach dep,$$$$(filter +python3-%,$$$$(DEPENDS)),$$$$(dep)-src)
  endef

  define Package/$(1)-src/description
    $(call Package/$(1)/description).
    (Contains the Python3 sources for this package).
  endef

  # Add default PyPackage filespec none defined
  ifndef Py3Package/$(1)/filespec
    define Py3Package/$(1)/filespec
      +|$(PYTHON3_PKG_DIR)
    endef
  endif

  ifndef Py3Package/$(1)/install
    define Py3Package/$(1)/install
		if [ -d $(PKG_INSTALL_DIR)/usr/bin ]; then \
			$(INSTALL_DIR) $$(1)/usr/bin ; \
			$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $$(1)/usr/bin/ ; \
		fi
    endef
  endif

  ifndef Package/$(1)/install
  $(call shexport,Py3Package/$(1)/filespec)

  define Package/$(1)/install
	$(call Py3Package/$(1)/install,$$(1))
	find $(PKG_INSTALL_DIR) -name "*\.exe" | xargs rm -f
	if [ -e files/python3-package-install.sh ] ; then \
		$(SHELL) files/python3-package-install.sh \
			"$(PKG_INSTALL_DIR)" "$$(1)" \
			"$(HOST_PYTHON3_BIN)" "$$(2)" \
			"$$$$$$$$$$(call shvar,Py3Package/$(1)/filespec)" ; \
	elif [ -e $(STAGING_DIR)/mk/python3-package-install.sh ] ; then \
		$(SHELL) $(STAGING_DIR)/mk/python3-package-install.sh \
			"$(PKG_INSTALL_DIR)" "$$(1)" \
			"$(HOST_PYTHON3_BIN)" "$$(2)" \
			"$$$$$$$$$$(call shvar,Py3Package/$(1)/filespec)" ; \
	else \
		echo "No 'python3-package-install.sh' script found" ; \
		exit 1 ; \
	fi
  endef

  define Package/$(1)-src/install
	$$(call Package/$(1)/install,$$(1),sources)
  endef
  endif # Package/$(1)/install
endef

$(call include_mk, python3-host.mk)

# $(1) => commands to execute before running pythons script
# $(2) => python script and its arguments
# $(3) => additional variables
define Build/Compile/HostPy3RunTarget
	$(call HostPython3, \
		$(if $(1),$(1);) \
		CC="$(TARGET_CC)" \
		CCSHARED="$(TARGET_CC) $(FPIC)" \
		CXX="$(TARGET_CXX)" \
		LD="$(TARGET_CC)" \
		LDSHARED="$(TARGET_CC) -shared" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="$(TARGET_CPPFLAGS) -I$(PYTHON3_INC_DIR)" \
		LDFLAGS="$(TARGET_LDFLAGS) -lpython$(PYTHON3_VERSION)" \
		_PYTHON_HOST_PLATFORM=linux2 \
		__PYVENV_LAUNCHER__="/usr/bin/$(PYTHON3)" \
		$(3) \
		, \
		$(2) \
	)
endef

# $(1) => build subdir
# $(2) => additional arguments to setup.py
# $(3) => additional variables
define Build/Compile/Py3Mod
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/$(PYTHON3_PKG_DIR)
	$(call Build/Compile/HostPy3RunTarget, \
		cd $(PKG_BUILD_DIR)/$(strip $(1)), \
		./setup.py $(2), \
		$(3))
	find $(PKG_INSTALL_DIR) -name "*\.exe" | xargs rm -f
endef

define Py3Build/Compile/Default
	$(foreach pkg,$(HOST_PYTHON3_PACKAGE_BUILD_DEPENDS),
		$(call host_python3_pip_install_host,$(pkg))
	)
	$(call Build/Compile/Py3Mod,, \
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)" \
		--single-version-externally-managed \
	)
endef

Py3Build/Compile=$(Py3Build/Compile/Default)

ifeq ($(BUILD_VARIANT),python3)
define Build/Compile
	$(call Py3Build/Compile)
endef
endif # python3
