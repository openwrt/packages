#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

# The file included below defines PYTHON3_VERSION
include ../python3-version.mk

PKG_NAME:=python3
PKG_RELEASE:=1
PKG_VERSION:=$(PYTHON3_VERSION).$(PYTHON3_VERSION_MICRO)

PKG_SOURCE:=Python-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.python.org/ftp/python/$(PKG_VERSION)
PKG_HASH:=0fab78fa7f133f4f38210c6260d90d7c0d5c7198446419ce057ec7ac2e6f5f38

PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>
PKG_LICENSE:=Python-2.0.1 0BSD
PKG_LICENSE_FILES:=LICENSE Doc/copyright.rst Doc/license.rst Modules/_ctypes/darwin/LICENSE Modules/_ctypes/libffi_osx/LICENSE Modules/expat/COPYING
PKG_CPE_ID:=cpe:/a:python:python

# This file provides the necsessary host build variables
include ../python3-host.mk

# For Py3Package
PYTHON3_PKG_BUILD:=0
include ../python3-package.mk

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
HOST_BUILD_PARALLEL:=1
# LTO is handled here individually, see --with-lto below
# "no-lto" prevents CONFIG_USE_LTO to add additional and interfering flags
PKG_BUILD_FLAGS:=no-lto

PKG_BUILD_DIR:=$(BUILD_DIR)/Python-$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/Python-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=bluez python3/host python-build/host python-installer/host python-wheel/host
HOST_BUILD_DEPENDS:=bzip2/host libffi/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/python3/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python $(PYTHON3_VERSION)
  URL:=https://www.python.org/
endef

define Package/python3/Default/description
Python is an interpreted, interactive, object-oriented programming
language. It incorporates modules, exceptions, dynamic typing, very high
level dynamic data types, and classes. It supports multiple programming
paradigms beyond object-oriented programming, such as procedural and
functional programming. Python combines remarkable power with very clear
syntax. It has interfaces to many system calls and libraries, as well as
to various window systems, and is extensible in C or C++. It is also
usable as an extension language for applications that need a
programmable interface. Finally, Python is portable: it runs on many
Unix variants including Linux and macOS, and on Windows.
endef

define Package/libpython3
$(call Package/python3/Default)
  TITLE+= core library
  DEPENDS:=+libpthread
  ABI_VERSION:=$(PYTHON3_VERSION)
endef

define Package/libpython3/description
$(call Package/python3/Default/description)

This package contains only core Python library.
endef

define Package/python3-base
$(call Package/python3/Default)
  TITLE+= base interpreter
  DEPENDS:=+libpython3
endef

define Package/python3-base/description
$(call Package/python3/Default/description)

This package contains only the interpreter and the bare minimum for the
interpreter to start.
endef

define Package/python3-light
$(call Package/python3/Default)
  TITLE+= light installation
  DEPENDS:=+python3-base +libbz2 +zlib
endef

define Package/python3-light/config
  source "$(SOURCE)/Config-python3-light.in"
endef

define Package/python3-light/description
$(call Package/python3/Default/description)

This package installs the base interpreter package and contains the most
commonly used parts of the standard library.
endef

PYTHON3_LIB_FILES_DEL:=
PYTHON3_PACKAGES:=
PYTHON3_SO_SUFFIX:=cpython-$(PYTHON3_VERSION_MAJOR)$(PYTHON3_VERSION_MINOR)-*.so
PYTHON3_PACKAGES_DEPENDS:=
define Py3BasePackage
  PYTHON3_PACKAGES+=$(1)
  ifeq ($(3),)
    PYTHON3_PACKAGES_DEPENDS+=$(1)
  endif
  PYTHON3_LIB_FILES_DEL+=$(2)
  ifeq ($(2),)
    Py3Package/$(1)/filespec=
  else
    define Py3Package/$(1)/filespec
      $(foreach lib_file,$(2),
        +|$(lib_file)
      )
    endef
  endif
  Py3Package/$(1)/install?=:
endef

include ./files/python3-package-*.mk

define Package/python3
$(call Package/python3/Default)
  TITLE+= programming language
  DEPENDS:=+python3-light $(foreach package,$(PYTHON3_PACKAGES_DEPENDS),+$(package))
endef

define Package/python3/description
$(call Package/python3/Default/description)

This package installs almost all parts of the standard Python
installation.
endef

# Set READELF here so that the exact same readelf program name can be
# replaced in _sysconfigdata_*.py (in Build/Install)
TARGET_CONFIGURE_OPTS+= \
	READELF="$(TARGET_CROSS)readelf"

EXTRA_LDFLAGS+= \
	-L$(PKG_BUILD_DIR) \
	-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib

# Bypass configure tests for cross compilation
CONFIGURE_VARS += \
	ac_cv_buggy_getaddrinfo=no \
	ac_cv_file__dev_ptc=no \
	ac_cv_file__dev_ptmx=yes

# Disable stdlib modules
# Check for a better way in the future: https://github.com/python/cpython/issues/98558
CONFIGURE_VARS += \
	py_cv_module__tkinter=n/a \
	py_cv_module_nis=n/a

# Workaround for hardfloat mips
# https://bugs.python.org/issue46265
ifneq ($(findstring mips,$(CONFIG_ARCH)),)
ifeq ($(CONFIG_HAS_FPU),y)
CONFIGURE_VARS += \
	ax_cv_check_cflags___fno_semantic_interposition=no
endif
endif

MAKE_VARS += \
	PYTHONSTRICTEXTENSIONBUILD=1

CONFIGURE_ARGS += \
	--enable-optimizations \
	--enable-shared \
	--disable-test-modules \
	--with-build-python \
	--with-system-ffi \
	--without-cxx-main \
	--without-ensurepip \
	$(if $(CONFIG_IPV6),--enable-ipv6) \
	$(if $(findstring mips,$(CONFIG_ARCH)),,--with-lto)

define Build/Install
	$(call Build/Install/Default,)

	$(SED) 's|$(TARGET_AR)|ar|g;s|$(TARGET_CROSS)readelf|readelf|g;s|$(TARGET_CC)|gcc|g;s|$(TARGET_CXX)|g++|g' \
		$(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON3_VERSION)/_sysconfigdata_*.py \
		$(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON3_VERSION)/config-$(PYTHON3_VERSION)-*/Makefile
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/python$(PYTHON3_VERSION) \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON3_VERSION) \
		$(PKG_INSTALL_DIR)/usr/lib/libpython$(PYTHON3_VERSION).so* \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/python$(PYTHON3_VERSION)/openwrt
	grep -E \
		'^(_PYTHON_HOST_PLATFORM|ABIFLAGS|MACHDEP|MULTIARCH)=' \
		$(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON3_VERSION)/config-$(PYTHON3_VERSION)-*/Makefile > \
		$(1)/usr/lib/python$(PYTHON3_VERSION)/openwrt/Makefile-vars

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/python*.pc \
		$(1)/usr/lib/pkgconfig

	$(INSTALL_DIR) $(2)/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/python$(PYTHON3_VERSION)-config \
		$(2)/bin/
	$(SED) \
		's|^prefix_real=.*$$$$|prefix_real="$(PYTHON3_DIR)"|' \
		$(2)/bin/python$(PYTHON3_VERSION)-config
endef

PYTHON3_BASE_LIB_FILES:= \
	/usr/lib/python$(PYTHON3_VERSION)/encodings \
	/usr/lib/python$(PYTHON3_VERSION)/_collections_abc.py \
	/usr/lib/python$(PYTHON3_VERSION)/_sitebuiltins.py \
	/usr/lib/python$(PYTHON3_VERSION)/_sysconfigdata_*.py \
	/usr/lib/python$(PYTHON3_VERSION)/_weakrefset.py \
	/usr/lib/python$(PYTHON3_VERSION)/abc.py \
	/usr/lib/python$(PYTHON3_VERSION)/codecs.py \
	/usr/lib/python$(PYTHON3_VERSION)/genericpath.py \
	/usr/lib/python$(PYTHON3_VERSION)/io.py \
	/usr/lib/python$(PYTHON3_VERSION)/os.py \
	/usr/lib/python$(PYTHON3_VERSION)/posixpath.py \
	/usr/lib/python$(PYTHON3_VERSION)/site.py \
	/usr/lib/python$(PYTHON3_VERSION)/sysconfig.py \
	/usr/lib/python$(PYTHON3_VERSION)/stat.py

PYTHON3_LIB_FILES_DEL+=$(PYTHON3_BASE_LIB_FILES)

define Py3Package/python3-base/filespec
+|/usr/bin/python$(PYTHON3_VERSION)
$(foreach lib_file,$(PYTHON3_BASE_LIB_FILES),
  +|$(lib_file)
)
endef

define Py3Package/python3-light/filespec
+|/usr/lib/python$(PYTHON3_VERSION)
-|/usr/lib/python$(PYTHON3_VERSION)/distutils/cygwinccompiler.py
-|/usr/lib/python$(PYTHON3_VERSION)/idlelib
-|/usr/lib/python$(PYTHON3_VERSION)/tkinter
-|/usr/lib/python$(PYTHON3_VERSION)/turtledemo
-|/usr/lib/python$(PYTHON3_VERSION)/webbrowser.py
-|/usr/lib/python$(PYTHON3_VERSION)/_osx_support.py
$(foreach lib_file,$(filter /usr/lib/python$(PYTHON3_VERSION)/%,$(PYTHON3_LIB_FILES_DEL)),
  -|$(lib_file)
)
endef

define Package/libpython3/install
	# Adding the lib-dynload folder (even just empty) suppresses 2 warnings when starting Python
	$(INSTALL_DIR) $(1)/usr/lib/python$(PYTHON3_VERSION)/lib-dynload/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpython$(PYTHON3_VERSION).so* $(1)/usr/lib/
endef

define Py3Package/python3-base/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(LN) python$(PYTHON3_VERSION) $(1)/usr/bin/python3
	$(LN) python$(PYTHON3_VERSION) $(1)/usr/bin/python
endef

Py3Package/python3-light/install:=:
Package/python3/install:=:

# libuuid is provided by e2fsprogs and uuid/uuid.h is moved into
# $(STAGING_DIR_HOST)/include/e2fsprogs
HOST_CFLAGS += \
	-I$(STAGING_DIR_HOST)/include/e2fsprogs
HOST_CPPFLAGS += \
	-I$(STAGING_DIR_HOST)/include/e2fsprogs

HOST_LDFLAGS += \
	-Wl$(comma)-rpath$(comma)$(STAGING_DIR_HOSTPKG)/lib

ifeq ($(HOST_OS),Linux)
HOST_LDFLAGS += \
	-Wl,--no-as-needed -lrt
endif

# Would be nice to be able to do this, but hosts are very fiddly
# HOST_MAKE_VARS += \
# 	PYTHONSTRICTEXTENSIONBUILD=1

# Bypass configure test
HOST_CONFIGURE_VARS += \
	ac_cv_working_openssl_hashlib=yes

ifeq ($(HOST_OS),Darwin)
HOST_CONFIGURE_VARS += \
	ac_cv_header_libintl_h=no
HOST_MAKE_VARS += \
	USE_PYTHON_CONFIG_PY=1
endif

HOST_CONFIGURE_ARGS += \
	--enable-optimizations \
	--disable-test-modules \
	--with-ensurepip=upgrade \
	--with-ssl-default-suites=openssl \
	--with-system-expat \
	--without-cxx-main

define Host/Configure
	$(SED) 's/^ENABLE_USER_SITE = None$$$$/ENABLE_USER_SITE = False/' $(HOST_BUILD_DIR)/Lib/site.py
	$(call Host/Configure/Default)
	ls $(HOST_BUILD_DIR)/Lib/ensurepip/_bundled/setuptools-$(PYTHON3_SETUPTOOLS_VERSION)-py3-none-any.whl
	ls $(HOST_BUILD_DIR)/Lib/ensurepip/_bundled/pip-$(PYTHON3_PIP_VERSION)-py3-none-any.whl
endef

define Host/Install
	$(if $(wildcard $(HOST_PYTHON3_PKG_DIR)/.setuptools_installed_$(PYTHON3_SETUPTOOLS_VERSION)-$(PYTHON3_SETUPTOOLS_PKG_RELEASE)),,
		rm -rf \
			$(HOST_PYTHON3_PKG_DIR)/pkg_resources \
			$(HOST_PYTHON3_PKG_DIR)/setuptools \
			$(HOST_PYTHON3_PKG_DIR)/setuptools-* \
			$(HOST_PYTHON3_PKG_DIR)/.setuptools-patched* \
			$(HOST_PYTHON3_PKG_DIR)/.setuptools_installed_*
	)
	$(if $(wildcard $(HOST_PYTHON3_PKG_DIR)/.pip_installed_$(PYTHON3_PIP_VERSION)-$(PYTHON3_PIP_PKG_RELEASE)),,
		rm -rf \
			$(HOST_PYTHON3_PKG_DIR)/pip \
			$(HOST_PYTHON3_PKG_DIR)/pip-* \
			$(HOST_PYTHON3_PKG_DIR)/.pip-patched* \
			$(HOST_PYTHON3_PKG_DIR)/.pip_installed_*
	)
	$(call Host/Install/Default)
	$(if $(wildcard $(HOST_PYTHON3_PKG_DIR)/.setuptools_installed_$(PYTHON3_SETUPTOOLS_VERSION)-$(PYTHON3_SETUPTOOLS_PKG_RELEASE)),,
		$(call HostPatchDir,$(HOST_PYTHON3_PKG_DIR),./patches-host-setuptools,)
		touch $(HOST_PYTHON3_PKG_DIR)/.setuptools_installed_$(PYTHON3_SETUPTOOLS_VERSION)-$(PYTHON3_SETUPTOOLS_PKG_RELEASE)
	)
	$(if $(wildcard $(HOST_PYTHON3_PKG_DIR)/.pip_installed_$(PYTHON3_PIP_VERSION)-$(PYTHON3_PIP_PKG_RELEASE)),,
		$(call HostPatchDir,$(HOST_PYTHON3_PKG_DIR),./patches-host-pip,)
		touch $(HOST_PYTHON3_PKG_DIR)/.pip_installed_$(PYTHON3_PIP_VERSION)-$(PYTHON3_PIP_PKG_RELEASE)
	)
endef

$(eval $(call HostBuild))

$(eval $(call BuildPackage,libpython3))
$(eval $(call BuildPackage,python3))

$(eval $(call Py3Package,python3-base))
$(eval $(call Py3Package,python3-light))

$(eval $(call BuildPackage,python3-base))
$(eval $(call BuildPackage,python3-light))

$(eval $(call BuildPackage,python3-base-src))
$(eval $(call BuildPackage,python3-light-src))

$(foreach package, $(PYTHON3_PACKAGES),  \
	$(eval $(call Py3Package,$(package))) \
	$(eval $(call BuildPackage,$(package))) \
	$(eval $(call BuildPackage,$(package)-src)) \
)
