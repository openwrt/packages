#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

python3_mk_path:=$(dir $(lastword $(MAKEFILE_LIST)))
include $(python3_mk_path)python3-host.mk

PYTHON3_HOST_BUILD?=1

PYTHON3_HOST_BUILD_CONFIG_SETTINGS?=
PYTHON3_HOST_BUILD_VARS?=
PYTHON3_HOST_BUILD_ARGS?=
PYTHON3_HOST_BUILD_PATH?=

PYTHON3_HOST_INSTALL_VARS?=

PYTHON3_HOST_WHEEL_NAME?=$(subst -,_,$(if $(PYPI_SOURCE_NAME),$(PYPI_SOURCE_NAME),$(PKG_NAME)))
PYTHON3_HOST_WHEEL_VERSION?=$(PKG_VERSION)

PYTHON3_HOST_BUILD_DIR?=$(HOST_BUILD_DIR)/$(PYTHON3_HOST_BUILD_PATH)


PYTHON3_HOST_DIR_NAME:=$(lastword $(subst /,$(space),$(CURDIR)))
PYTHON3_HOST_STAGING_DIR:=$(TMP_DIR)/host-stage-$(PYTHON3_HOST_DIR_NAME)
PYTHON3_HOST_STAGING_FILES_LIST_DIR:=$(HOST_BUILD_PREFIX)/stamp
PYTHON3_HOST_STAGING_FILES_LIST:=$(PYTHON3_HOST_STAGING_FILES_LIST_DIR)/$(PYTHON3_HOST_DIR_NAME).list

define Py3Host/Compile/Bootstrap
	$(call HostPython3/Run, \
		$(HOST_BUILD_DIR), \
		-m flit_core.wheel \
			--outdir "$(PYTHON3_HOST_BUILD_DIR)"/openwrt-build \
			"$(PYTHON3_HOST_BUILD_DIR)" \
	)
endef

define Py3Host/Compile
	$(call HostPython3/Run, \
		$(HOST_BUILD_DIR), \
		-m build \
			--no-isolation \
			--outdir "$(PYTHON3_HOST_BUILD_DIR)"/openwrt-build \
			--wheel \
			$(foreach setting,$(PYTHON3_HOST_BUILD_CONFIG_SETTINGS),--config-setting=$(setting)) \
			$(PYTHON3_HOST_BUILD_ARGS) \
			"$(PYTHON3_HOST_BUILD_DIR)" \
			, \
		$(PYTHON3_HOST_BUILD_VARS) \
	)
endef

define Py3Host/Install/Installer
	$(call HostPython3/Run, \
		$(HOST_BUILD_DIR), \
		-m installer \
			--destdir "$(1)" \
			--prefix "" \
			"$(PYTHON3_HOST_BUILD_DIR)"/openwrt-build/$(PYTHON3_HOST_WHEEL_NAME)-$(PYTHON3_HOST_WHEEL_VERSION)-*.whl \
			, \
		$(PYTHON3_HOST_INSTALL_VARS) \
	)
endef

define Py3Host/Install
	rm -rf "$(PYTHON3_HOST_STAGING_DIR)"
	mkdir -p "$(PYTHON3_HOST_STAGING_DIR)" "$(PYTHON3_HOST_STAGING_FILES_LIST_DIR)"

	$(call Py3Host/Install/Installer,$(PYTHON3_HOST_STAGING_DIR))

	$(call Py3Host/Uninstall,$(1))

	cd "$(PYTHON3_HOST_STAGING_DIR)" && find ./ > "$(PYTHON3_HOST_STAGING_DIR).files"

	$(call locked, \
		mv "$(PYTHON3_HOST_STAGING_DIR).files" "$(PYTHON3_HOST_STAGING_FILES_LIST)" && \
		$(CP) "$(PYTHON3_HOST_STAGING_DIR)"/* "$(1)/", \
		host-staging-dir \
	)

	rm -rf "$(PYTHON3_HOST_STAGING_DIR)"
endef

define Py3Host/Uninstall
	if [ -f "$(PYTHON3_HOST_STAGING_FILES_LIST)" ]; then \
		"$(SCRIPT_DIR)/clean-package.sh" \
			"$(PYTHON3_HOST_STAGING_FILES_LIST)" \
			"$(1)" ; \
		rm -f "$(PYTHON3_HOST_STAGING_FILES_LIST)" ; \
	fi
endef

ifeq ($(strip $(PYTHON3_HOST_BUILD)),1)
  Host/Compile=$(Py3Host/Compile)
  Host/Install=$(Py3Host/Install)
  Host/Uninstall=$(call Py3Host/Uninstall,$(HOST_BUILD_PREFIX))
endif
