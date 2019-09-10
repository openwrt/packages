#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

# For PYTHON_VERSION
include ../python-version.mk

PKG_NAME:=python
PKG_VERSION:=$(PYTHON_VERSION).$(PYTHON_VERSION_MICRO)
PKG_RELEASE:=2

PKG_SOURCE:=Python-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.python.org/ftp/python/$(PKG_VERSION)
PKG_HASH:=4d43f033cdbd0aa7b7023c81b0e986fd11e653b5248dac9144d508f11812ba41

PKG_LICENSE:=Python/2.0
PKG_LICENSE_FILES:=LICENSE Doc/copyright.rst Doc/license.rst Modules/_ctypes/darwin/LICENSE Modules/_ctypes/libffi/LICENSE Modules/_ctypes/libffi_osx/LICENSE Modules/expat/COPYING
PKG_CPE_ID:=cpe:/a:python:python

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>, Jeffery To <jeffery.to@gmail.com>

# This file provides the necsessary host build variables
include ../python-host.mk

# For PyPackage
include ../python-package.mk

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
HOST_BUILD_PARALLEL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/Python-$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/Python-$(PKG_VERSION)

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_python-pkg-resources \
	CONFIG_PACKAGE_python-setuptools CONFIG_PACKAGE_python-pip \
	CONFIG_PYTHON_BLUETOOTH_SUPPORT

PKG_BUILD_DEPENDS:=python/host
HOST_BUILD_DEPENDS:=bzip2/host expat/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/python/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python $(PYTHON_VERSION) programming language
  URL:=https://www.python.org/
endef

define Package/python/Default/description
 Python is a dynamic object-oriented programming language that can be used
 for many kinds of software development. It offers strong support for
 integration with other languages and tools, comes with extensive standard
 libraries, and can be learned in a few days. Many Python programmers
 report substantial productivity gains and feel the language encourages
 the development of higher quality, more maintainable code.
endef

define Package/python-base
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) interpreter
  DEPENDS:=+libpthread +zlib
endef

define Package/python-base/description
  This package contains only the interpreter and the bare minimum
  for the interpreter to start.
endef

define Package/python-light
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) light installation
  DEPENDS:=+python-base +libffi +libbz2 +PYTHON_BLUETOOTH_SUPPORT:bluez-libs
endef

define Package/python-light/config
  source "$(SOURCE)/Config-python-light.in"
endef

define Package/python-light/description
  This package is essentially the python-base package plus
  a few of the rarely used (and big) libraries stripped out
  into separate packages.
endef

PYTHON_LIB_FILES_DEL:=
PYTHON_PACKAGES:=
PYTHON_PACKAGES_DEPENDS:=
define PyBasePackage
  PYTHON_PACKAGES+=$(1)
  ifeq ($(3),)
    PYTHON_PACKAGES_DEPENDS+=$(1)
  endif
  PYTHON_LIB_FILES_DEL+=$(2)
  define PyPackage/$(1)/filespec
    ifneq ($(2),)
      $(subst $(space),$(newline),$(foreach lib_file,$(2),+|$(lib_file)))
      -|/usr/lib/python$(PYTHON_VERSION)/*/test
      -|/usr/lib/python$(PYTHON_VERSION)/*/tests
    endif
  endef
  PyPackage/$(1)/install?=:
endef

include ./files/python-package-*.mk

define Package/python
$(call Package/python/Default)
  DEPENDS:=+python-light $(foreach package,$(PYTHON_PACKAGES_DEPENDS),+$(package))
endef

define Package/python/description
  This package contains the (almost) full Python install.
  It's python-light + all other packages.
endef

MAKE_FLAGS+=\
	CROSS_COMPILE=yes \
	LD="$(TARGET_CC)" \
	PGEN=pgen2

EXTRA_CFLAGS+= \
	-DNDEBUG -fno-inline
EXTRA_LDFLAGS+= \
	-L$(PKG_BUILD_DIR)

ENABLE_IPV6:=
ifeq ($(CONFIG_IPV6),y)
	ENABLE_IPV6 += --enable-ipv6
endif

PYTHON_FOR_BUILD:= \
	_PYTHON_PROJECT_BASE=$(PKG_BUILD_DIR) \
	_PYTHON_HOST_PLATFORM=linux2 \
	PYTHONPATH="$(PKG_BUILD_DIR)/Lib:$(PKG_BUILD_DIR)/build/lib.linux2-$(PYTHON_VERSION)" \
	_PYTHON_SYSCONFIGDATA_NAME=_sysconfigdata \
	$(HOST_PYTHON_BIN)

DISABLE_BLUETOOTH:= \
    ac_cv_header_bluetooth_bluetooth_h=no \
    ac_cv_header_bluetooth_h=no

CONFIGURE_ARGS+= \
	--sysconfdir=/etc \
	--enable-shared \
	--without-cxx-main \
	--with-threads \
	--with-system-ffi \
	--with-ensurepip=no \
	--without-pymalloc \
	$(if $(CONFIG_PYTHON_BLUETOOTH_SUPPORT),,$(DISABLE_BLUETOOTH)) \
	PYTHON_FOR_BUILD="$(PYTHON_FOR_BUILD)" \
	$(ENABLE_IPV6) \
	CONFIG_SITE="$(PKG_BUILD_DIR)/config.site" \
	OPT="$(TARGET_CFLAGS)"

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) ./files/config.site $(PKG_BUILD_DIR)/config.site
endef

ifdef CONFIG_PACKAGE_python-setuptools
PYTHON_SETUPTOOLS_BUILD:=1
endif

ifdef CONFIG_PACKAGE_python-pkg-resources
PYTHON_SETUPTOOLS_BUILD:=1
endif

ifeq ($(PYTHON_SETUPTOOLS_BUILD),1)
define Build/Compile/python-setuptools
	$(HOST_PYTHON_PIP) \
		--disable-pip-version-check \
		--cache-dir "$(DL_DIR)/pip-cache" \
		install \
		--ignore-installed \
		--root=$(PKG_BUILD_DIR)/install-setuptools \
		--prefix=/usr \
		$(PKG_BUILD_DIR)/Lib/ensurepip/_bundled/setuptools-$(PYTHON_SETUPTOOLS_VERSION)-py2.py3-none-any.whl
	$(call PatchDir,$(PKG_BUILD_DIR)/install-setuptools/usr/lib/python$(PYTHON_VERSION)/site-packages,./patches-setuptools,)
endef
endif # CONFIG_PACKAGE_python-setuptools

ifdef CONFIG_PACKAGE_python-pip
define Build/Compile/python-pip
	$(HOST_PYTHON_PIP) \
		--disable-pip-version-check \
		--cache-dir "$(DL_DIR)/pip-cache" \
		install \
		--ignore-installed \
		--root=$(PKG_BUILD_DIR)/install-pip \
		--prefix=/usr \
		$(PKG_BUILD_DIR)/Lib/ensurepip/_bundled/pip-$(PYTHON_PIP_VERSION)-py2.py3-none-any.whl
	$(call PatchDir,$(PKG_BUILD_DIR)/install-pip/usr/lib/python$(PYTHON_VERSION)/site-packages,./patches-pip,)
endef
endif # CONFIG_PACKAGE_python-pip

define Build/Compile
	$(call Build/Compile/Default)
	# Use host pip to install python-setuptools
	$(call Build/Compile/python-setuptools)
	$(call Build/Compile/python-pip)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib $(1)/usr/lib/pkgconfig
	$(INSTALL_DIR) $(2)/bin
	$(INSTALL_DIR) $(1)/usr/lib/python$(PYTHON_VERSION)-openwrt
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/python$(PYTHON_VERSION) \
		$(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON_VERSION) \
		$(PKG_INSTALL_DIR)/usr/lib/libpython$(PYTHON_VERSION).so* \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/python*.pc \
		$(1)/usr/lib/pkgconfig
	$(INSTALL_BIN) \
		./files/python-config.in \
		$(2)/bin/python$(PYTHON_VERSION)-config
	$(SED) \
		's|@EXENAME@|$(HOST_PYTHON_DIR)/bin/python$(PYTHON_VERSION)|' \
		-e 's|@TARGET_PREFIX@|$(PYTHON_DIR)|' \
		$(2)/bin/python$(PYTHON_VERSION)-config
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON_VERSION)/_sysconfigdata.py \
		$(1)/usr/lib/python$(PYTHON_VERSION)-openwrt/_sysconfigdatatarget.py
endef

PYTHON_BASE_LIB_FILES:= \
	/usr/lib/python$(PYTHON_VERSION)/_abcoll.py \
	/usr/lib/python$(PYTHON_VERSION)/_sysconfigdata.py \
	/usr/lib/python$(PYTHON_VERSION)/_weakrefset.py \
	/usr/lib/python$(PYTHON_VERSION)/abc.py \
	/usr/lib/python$(PYTHON_VERSION)/copy_reg.py \
	/usr/lib/python$(PYTHON_VERSION)/genericpath.py \
	/usr/lib/python$(PYTHON_VERSION)/linecache.py \
	/usr/lib/python$(PYTHON_VERSION)/posixpath.py \
	/usr/lib/python$(PYTHON_VERSION)/os.py \
	/usr/lib/python$(PYTHON_VERSION)/re.py \
	/usr/lib/python$(PYTHON_VERSION)/site.py \
	/usr/lib/python$(PYTHON_VERSION)/sre_compile.py \
	/usr/lib/python$(PYTHON_VERSION)/sre_constants.py \
	/usr/lib/python$(PYTHON_VERSION)/sre_parse.py \
	/usr/lib/python$(PYTHON_VERSION)/sysconfig.py \
	/usr/lib/python$(PYTHON_VERSION)/stat.py \
	/usr/lib/python$(PYTHON_VERSION)/traceback.py \
	/usr/lib/python$(PYTHON_VERSION)/types.py \
	/usr/lib/python$(PYTHON_VERSION)/UserDict.py \
	/usr/lib/python$(PYTHON_VERSION)/warnings.py

PYTHON_LIB_FILES_DEL+=$(PYTHON_BASE_LIB_FILES)

define PyPackage/python-base/filespec
+|/usr/bin/python$(PYTHON_VERSION)
$(subst $(space),$(newline),$(foreach lib_file,$(PYTHON_BASE_LIB_FILES),+|$(lib_file)))
endef

define PyPackage/python-light/filespec
+|/usr/lib/python$(PYTHON_VERSION)
-|/usr/lib/python$(PYTHON_VERSION)/distutils/cygwinccompiler.py
-|/usr/lib/python$(PYTHON_VERSION)/distutils/command/wininst*
-|/usr/lib/python$(PYTHON_VERSION)/ensurepip
-|/usr/lib/python$(PYTHON_VERSION)/idlelib
-|/usr/lib/python$(PYTHON_VERSION)/lib-tk
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_testcapi.so
-|/usr/lib/python$(PYTHON_VERSION)/pdb.doc
-|/usr/lib/python$(PYTHON_VERSION)/test
-|/usr/lib/python$(PYTHON_VERSION)/webbrowser.py
-|/usr/lib/python$(PYTHON_VERSION)/*/test
-|/usr/lib/python$(PYTHON_VERSION)/*/tests
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/readline.so
$(subst $(space),$(newline),$(foreach lib_file,$(PYTHON_LIB_FILES_DEL),-|$(lib_file)))
endef

define PyPackage/python-base/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib
	$(LN) python$(PYTHON_VERSION) $(1)/usr/bin/python
	$(LN) python$(PYTHON_VERSION) $(1)/usr/bin/python2
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpython$(PYTHON_VERSION).so* $(1)/usr/lib/
endef

PyPackage/python-light/install:=:
PyPackage/python/install:=:

define PyPackage/python/filespec
-|$(PYTHON_PKG_DIR)
endef

HOST_LDFLAGS += \
	-Wl$(comma)-rpath$(comma)$(STAGING_DIR_HOSTPKG)/lib

ifeq ($(HOST_OS),Linux)
HOST_LDFLAGS += \
	-Wl,--no-as-needed -lrt
endif

ifeq ($(HOST_OS),Darwin)
HOST_CONFIGURE_VARS += \
	ac_cv_header_libintl_h=no
endif

HOST_CONFIGURE_ARGS+= \
	--without-cxx-main \
	--without-pymalloc \
	--with-threads \
	--prefix=$(HOST_PYTHON_DIR) \
	--exec-prefix=$(HOST_PYTHON_DIR) \
	--with-system-expat=$(STAGING_DIR_HOSTPKG) \
	--with-ensurepip=upgrade \
	CONFIG_SITE=

define Host/Configure
	$(SED) 's/^ENABLE_USER_SITE = None$$$$/ENABLE_USER_SITE = False/' $(HOST_BUILD_DIR)/Lib/site.py
	$(call Host/Configure/Default)
endef

define Host/Compile
	$(call Host/Compile/Default,python Parser/pgen sharedmods)
endef

define Host/Install
	$(if $(wildcard $(HOST_PYTHON_PKG_DIR)/.setuptools_installed_$(PYTHON_SETUPTOOLS_VERSION)-$(PYTHON_SETUPTOOLS_PKG_RELEASE)),,
		rm -rf \
			$(HOST_PYTHON_PKG_DIR)/easy_install.py \
			$(HOST_PYTHON_PKG_DIR)/pkg_resources \
			$(HOST_PYTHON_PKG_DIR)/setuptools \
			$(HOST_PYTHON_PKG_DIR)/setuptools-* \
			$(HOST_PYTHON_PKG_DIR)/.setuptools-patched* \
			$(HOST_PYTHON_PKG_DIR)/.setuptools_installed_*
	)
	$(if $(wildcard $(HOST_PYTHON_PKG_DIR)/.pip_installed_$(PYTHON_PIP_VERSION)-$(PYTHON_PIP_PKG_RELEASE)),,
		rm -rf \
			$(HOST_PYTHON_PKG_DIR)/pip \
			$(HOST_PYTHON_PKG_DIR)/pip-* \
			$(HOST_PYTHON_PKG_DIR)/.pip-patched* \
			$(HOST_PYTHON_PKG_DIR)/.pip_installed_*
	)
	$(MAKE) -C $(HOST_BUILD_DIR) install
	$(INSTALL_DIR) $(HOST_PYTHON_DIR)/bin/
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/Parser/pgen $(HOST_PYTHON_DIR)/bin/pgen2
	$(if $(wildcard $(HOST_PYTHON_PKG_DIR)/.setuptools_installed_$(PYTHON_SETUPTOOLS_VERSION)-$(PYTHON_SETUPTOOLS_PKG_RELEASE)),,
		$(call HostPatchDir,$(HOST_PYTHON_PKG_DIR),./patches-setuptools,)
		touch $(HOST_PYTHON_PKG_DIR)/.setuptools_installed_$(PYTHON_SETUPTOOLS_VERSION)-$(PYTHON_SETUPTOOLS_PKG_RELEASE)
	)
	$(if $(wildcard $(HOST_PYTHON_PKG_DIR)/.pip_installed_$(PYTHON_PIP_VERSION)-$(PYTHON_PIP_PKG_RELEASE)),,
		$(call HostPatchDir,$(HOST_PYTHON_PKG_DIR),./patches-pip,)
		touch $(HOST_PYTHON_PKG_DIR)/.pip_installed_$(PYTHON_PIP_VERSION)-$(PYTHON_PIP_PKG_RELEASE)
	)
endef

$(eval $(call HostBuild))

$(foreach package, $(PYTHON_PACKAGES),  \
	$(eval $(call PyPackage,$(package))) \
	$(eval $(call BuildPackage,$(package))) \
	$(eval $(call BuildPackage,$(package)-src)) \
)

$(eval $(call PyPackage,python-base))
$(eval $(call PyPackage,python-light))
$(eval $(call PyPackage,python))

$(eval $(call BuildPackage,python-base))
$(eval $(call BuildPackage,python-light))
$(eval $(call BuildPackage,python))

$(eval $(call BuildPackage,python-base-src))
$(eval $(call BuildPackage,python-light-src))
