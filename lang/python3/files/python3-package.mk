#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

PYTHON3_VERSION:=3.4
PYTHON3_VERSION_MICRO:=1

PYTHON3_DIR:=$(STAGING_DIR)/usr
PYTHON3_BIN_DIR:=$(PYTHON3_DIR)/bin
PYTHON3_INC_DIR:=$(PYTHON3_DIR)/include/python$(PYTHON3_VERSION)
PYTHON3_LIB_DIR:=$(PYTHON3_DIR)/lib/python$(PYTHON3_VERSION)

PYTHON3_PKG_DIR:=/usr/lib/python$(PYTHON3_VERSION)/site-packages

PYTHON3:=python$(PYTHON3_VERSION)

HOST_PYTHON3_BIN:=$(STAGING_DIR_HOST)/bin/python3

define HostPython3
	(	export PYTHONPATH="$(PYTHON3_LIB_DIR):$(STAGING_DIR)/$(PYTHON3_PKG_DIR)"; \
		export PYTHONOPTIMIZE=""; \
		export PYTHONDONTWRITEBYTECODE=1; \
		$(1) \
		$(HOST_PYTHON3_BIN) $(2); \
	)
endef

define Py3Package
  $(call shexport,Py3Package/$(1)/filespec)

  define Package/$(1)/install
	find $(PKG_INSTALL_DIR) -name "*\.pyc" -o -name "*\.pyo" | xargs rm -f
	@echo "$$$$$$$$$$(call shvar,PyPackage/$(1)/filespec)" | ( \
		IFS='|'; \
		while read fop fspec fperm; do \
		  if [ "$$$$$$$$fop" = "+" ]; then \
			if [ ! -e "$(PKG_INSTALL_DIR)$$$$$$$$fspec" ]; then \
			  echo "File not found '$(PKG_INSTALL_DIR)$$$$$$$$fspec'"; \
			  exit 1; \
			fi; \
			dpath=`dirname "$$$$$$$$fspec"`; \
			if [ -n "$$$$$$$$fperm" ]; then \
			  dperm="-m$$$$$$$$fperm"; \
			else \
			  dperm=`stat -c "%a" $(PKG_INSTALL_DIR)$$$$$$$$dpath`; \
			fi; \
			mkdir -p $$$$$$$$$dperm $$(1)$$$$$$$$dpath; \
			echo "copying: '$$$$$$$$fspec'"; \
			cp -fpR $(PKG_INSTALL_DIR)$$$$$$$$fspec $$(1)$$$$$$$$dpath/; \
			if [ -n "$$$$$$$$fperm" ]; then \
			  chmod -R $$$$$$$$fperm $$(1)$$$$$$$$fspec; \
			fi; \
		  elif [ "$$$$$$$$fop" = "-" ]; then \
			echo "removing: '$$$$$$$$fspec'"; \
			rm -fR $$(1)$$$$$$$$fspec; \
		  elif [ "$$$$$$$$fop" = "=" ]; then \
			echo "setting permissions: '$$$$$$$$fperm' on '$$$$$$$$fspec'"; \
			chmod -R $$$$$$$$fperm $$(1)$$$$$$$$fspec; \
		  fi; \
		done; \
	)
	$(call Py3Package/$(1)/install,$$(1))
  endef
endef

# $(1) => build subdir
# $(2) => additional arguments to setup.py
# $(3) => additional variables
define Build/Compile/Py3Mod
	$(call HostPython3, \
		cd $(PKG_BUILD_DIR)/$(strip $(1)); \
		CC="$(TARGET_CC)" \
		CCSHARED="$(TARGET_CC) $(FPIC)" \
		LD="$(TARGET_CC)" \
		LDSHARED="$(TARGET_CC) -shared" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="$(TARGET_CPPFLAGS) -I$(PYTHON3_INC_DIR)" \
		LDFLAGS="$(TARGET_LDFLAGS) -lpython$(PYTHON3_VERSION)" \
		_PYTHON_HOST_PLATFORM="linux-$(ARCH)" \
		$(3) \
		, \
		./setup.py $(2) \
	)
	find $(PKG_INSTALL_DIR) -name "*\.pyc" -o -name "*\.pyo" | xargs rm -f
endef
