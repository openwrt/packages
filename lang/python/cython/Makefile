#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cython
PKG_VERSION:=0.25.2
PKG_RELEASE:=1

PKG_SOURCE:=Cython-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/b7/67/7e2a817f9e9c773ee3995c1e15204f5d01c8da71882016cac10342ef031b/
PKG_BUILD_DIR:=$(BUILD_DIR)/Cython-$(PKG_VERSION)
PKG_MD5SUM:=642c81285e1bb833b14ab3f439964086

PKG_BUILD_DEPENDS:=python cython/host
HOST_BUILD_DEPENDS:=python

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/Cython-$(PKG_VERSION)

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/cython
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=V.E.O <veo at live.com>
  TITLE:=The Cython compiler for writing C extensions for the Python language
  URL:=http://www.cython.org
  DEPENDS:=+python
endef

define Package/cython/description
Cython is an optimising static compiler for both the Python programming
language and the extended Cython programming language (based on Pyrex).
It makes writing C extensions for Python as easy as Python itself.
endef

define Build/Compile
	echo build-compile
	# <--no-cython-compile> required, otherwise setup.py calls the target-gcc to create so-files which obviously can't be used by <python> on the host system.
	$(call Build/Compile/PyMod,,install --no-cython-compile --prefix="/usr" --root="$(PKG_INSTALL_DIR)")
endef

#$(call Build/Compile/PyMod,,install --single-version-externally-managed --no-cython-compile --prefix="/usr" --root="$(PKG_INSTALL_DIR)")

define Build/InstallDev
	echo build-installdev
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)/usr/lib/python2.7/site-packages/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

# TODO: this should be moved to python package
# $(1) => build subdir
# $(2) => additional arguments to setup.py
# $(3) => additional variables
define Host/Compile/PyMod
        $(call HostPython, \
                cd $(HOST_BUILD_DIR)/$(strip $(1)); \
                CFLAGS="$(HOST_CFLAGS)" \
                CPPFLAGS="$(HOST_CPPFLAGS)" \
                LDFLAGS="$(HOST_LDFLAGS)" \
                $(3) \
                , \
                ./setup.py $(2) \
        )
endef

define Host/Compile
	echo host-compile
	$(call Host/Compile/PyMod,,install --no-cython-compile --prefix="/usr" --root="$(STAGING_DIR_HOST)")
endef

define Host/Install
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,cython))
