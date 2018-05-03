#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

# The file included below defines PYTHON_VERSION
include ../python3-version.mk

PYTHON_VERSION:=$(PYTHON3_VERSION)
PYTHON_VERSION_MICRO:=$(PYTHON3_VERSION_MICRO)

PKG_NAME:=python3
PKG_RELEASE:=1
PKG_VERSION:=$(PYTHON_VERSION).$(PYTHON_VERSION_MICRO)

PKG_SOURCE:=Python-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.python.org/ftp/python/$(PKG_VERSION)
PKG_HASH:=f434053ba1b5c8a5cc597e966ead3c5143012af827fd3f0697d21450bb8d87a6

PKG_LICENSE:=PSF
PKG_LICENSE_FILES:=LICENSE Modules/_ctypes/libffi_msvc/LICENSE Modules/_ctypes/darwin/LICENSE Modules/_ctypes/libffi/LICENSE Modules/_ctypes/libffi_osx/LICENSE Tools/pybench/LICENSE

# This file provides the necsessary host build variables
include ../python3-host.mk

# For Py3Package
include ../python3-package.mk

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
HOST_BUILD_PARALLEL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/Python-$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/Python-$(PKG_VERSION)

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_python3-setuptools CONFIG_PACKAGE_python3-pip \
	CONFIG_PYTHON3_BLUETOOTH_SUPPORT

PKG_BUILD_DEPENDS:=python3/host
HOST_BUILD_DEPENDS:=bzip2/host expat/host libffi/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/python3/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python $(PYTHON_VERSION) programming language
  URL:=https://www.python.org/
  MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
endef

define Package/python3/Default/description
 Python is a dynamic object-oriented programming language that can be used
 for many kinds of software development. It offers strong support for
 integration with other languages and tools, comes with extensive standard
 libraries, and can be learned in a few days. Many Python programmers
 report substantial productivity gains and feel the language encourages
 the development of higher quality, more maintainable code.
endef

define Package/python3-base
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON_VERSION) interpreter
  DEPENDS:=+libpthread +zlib
endef

define Package/python3-base/description
  This package contains only the interpreter and the bare minimum
  for the interpreter to start.
endef

define Package/python3-light
$(call Package/python3/Default)
  TITLE:=Python $(PYTHON_VERSION) light installation
  DEPENDS:=+python3-base +libffi +libbz2 +PYTHON3_BLUETOOTH_SUPPORT:bluez-libs
endef

define Package/python3-light/config
  source "$(SOURCE)/Config-python3-light.in"
endef

define Package/python3-light/description
  This package is essentially the python3-base package plus
  a few of the rarely used (and big) libraries stripped out
  into separate packages.
endef

PYTHON3_LIB_FILES_DEL:=
PYTHON3_PACKAGES:=
PYTHON3_SO_SUFFIX:=cpython-$(PYTHON3_VERSION_MAJOR)$(PYTHON3_VERSION_MINOR).so
PYTHON3_PACKAGES_DEPENDS:=
define Py3BasePackage
  PYTHON3_PACKAGES+=$(1)
  ifeq ($(3),)
    PYTHON3_PACKAGES_DEPENDS+=$(1)
  endif
  PYTHON3_LIB_FILES_DEL+=$(2)
  define Py3Package/$(1)/filespec
    ifneq ($(2),)
      $(subst $(space),$(newline),$(foreach lib_file,$(2),+|$(lib_file)))
      -|/usr/lib/python$(PYTHON_VERSION)/*/test
      -|/usr/lib/python$(PYTHON_VERSION)/*/tests
    endif
  endef
endef

include ./files/python3-package-*.mk

define Package/python3
$(call Package/python3/Default)
  DEPENDS:=+python3-light $(foreach package,$(PYTHON3_PACKAGES_DEPENDS),+$(package))
endef

define Package/python3/description
  This package contains the (almost) full Python install.
  It's python3-light + all other packages.
endef

MAKE_FLAGS+=\
	CROSS_COMPILE=yes \
	LD="$(TARGET_CC)" \
	PGEN=pgen3

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
	$(HOST_PYTHON3_BIN)

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
	$(if $(CONFIG_PYTHON3_BLUETOOTH_SUPPORT),,$(DISABLE_BLUETOOTH)) \
	PYTHON_FOR_BUILD="$(PYTHON_FOR_BUILD)" \
	$(ENABLE_IPV6) \
	CONFIG_SITE="$(PKG_BUILD_DIR)/config.site" \
	OPT="$(TARGET_CFLAGS)"

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) ./files/config.site $(PKG_BUILD_DIR)/config.site
endef

ifdef CONFIG_PACKAGE_python3-setuptools
define Build/Compile/python3-setuptools
	$(STAGING_DIR_HOSTPKG)/bin/pip3 install \
		--ignore-installed \
		--root=$(PKG_BUILD_DIR)/install-setuptools --prefix=. \
		$(PKG_BUILD_DIR)/Lib/ensurepip/_bundled/setuptools-*.whl
endef
endif # CONFIG_PACKAGE_python3-setuptools

ifdef CONFIG_PACKAGE_python3-pip
define Build/Compile/python3-pip
	$(STAGING_DIR_HOSTPKG)/bin/pip3 install \
		--ignore-installed \
		--root=$(PKG_BUILD_DIR)/install-pip --prefix=. \
		$(PKG_BUILD_DIR)/Lib/ensurepip/_bundled/pip-*.whl
endef
endif # CONFIG_PACKAGE_python3-pip

define Build/Compile
	$(call Build/Compile/Default)
	# Use host pip to install python-setuptools
	$(call Build/Compile/python3-setuptools)
	$(call Build/Compile/python3-pip)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/ $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/python$(PYTHON_VERSION)/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/python$(PYTHON_VERSION) \
		$(1)/usr/include/
	$(CP) \
		$(HOST_PYTHON3_LIB_DIR) \
		$(PKG_INSTALL_DIR)/usr/lib/libpython$(PYTHON_VERSION).so* \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON_VERSION)/config-$(PYTHON_VERSION) \
		$(1)/usr/lib/python$(PYTHON_VERSION)/
endef

PYTHON3_BASE_LIB_FILES:= \
	/usr/lib/python$(PYTHON_VERSION)/encodings \
	/usr/lib/python$(PYTHON_VERSION)/_collections_abc.py \
	/usr/lib/python$(PYTHON_VERSION)/_sitebuiltins.py \
	/usr/lib/python$(PYTHON_VERSION)/_sysconfigdata.py \
	/usr/lib/python$(PYTHON_VERSION)/_weakrefset.py \
	/usr/lib/python$(PYTHON_VERSION)/abc.py \
	/usr/lib/python$(PYTHON_VERSION)/codecs.py \
	/usr/lib/python$(PYTHON_VERSION)/genericpath.py \
	/usr/lib/python$(PYTHON_VERSION)/io.py \
	/usr/lib/python$(PYTHON_VERSION)/os.py \
	/usr/lib/python$(PYTHON_VERSION)/posixpath.py \
	/usr/lib/python$(PYTHON_VERSION)/site.py \
	/usr/lib/python$(PYTHON_VERSION)/sysconfig.py \
	/usr/lib/python$(PYTHON_VERSION)/stat.py

PYTHON3_LIB_FILES_DEL+=$(PYTHON3_BASE_LIB_FILES)

define Py3Package/python3-base/filespec
+|/usr/bin/python$(PYTHON_VERSION)
$(subst $(space),$(newline),$(foreach lib_file,$(PYTHON3_BASE_LIB_FILES),+|$(lib_file)))
endef

define Py3Package/python3-light/filespec
+|/usr/lib/python$(PYTHON_VERSION)
-|/usr/lib/python$(PYTHON_VERSION)/distutils/cygwinccompiler.py
-|/usr/lib/python$(PYTHON_VERSION)/distutils/command/wininst*
-|/usr/lib/python$(PYTHON_VERSION)/ensurepip
-|/usr/lib/python$(PYTHON_VERSION)/idlelib
-|/usr/lib/python$(PYTHON_VERSION)/tkinter
-|/usr/lib/python$(PYTHON_VERSION)/turtledemo
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_test*.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/readline*.so
-|/usr/lib/python$(PYTHON_VERSION)/pdb.doc
-|/usr/lib/python$(PYTHON_VERSION)/test
-|/usr/lib/python$(PYTHON_VERSION)/webbrowser.py
-|/usr/lib/python$(PYTHON_VERSION)/*/test
-|/usr/lib/python$(PYTHON_VERSION)/*/tests
-|/usr/lib/python$(PYTHON_VERSION)/_osx_support.py
$(subst $(space),$(newline),$(foreach lib_file,$(PYTHON3_LIB_FILES_DEL),-|$(lib_file)))
endef

define Py3Package/python3-base/install
	# Adding the lib-dynload folder (even just empty) suppresses 2 warnings when starting Python
	$(INSTALL_DIR) $(1)/usr/lib/python$(PYTHON_VERSION)/lib-dynload/
	$(INSTALL_DIR) $(1)/usr/bin
	$(LN) python$(PYTHON_VERSION) $(1)/usr/bin/python3
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpython$(PYTHON_VERSION).so* $(1)/usr/lib/
endef

define Py3Package/python3/filespec
-|$(PYTHON3_PKG_DIR)
endef

HOST_LDFLAGS += \
	$$$$(pkg-config --static --libs libcrypto libssl)

ifeq ($(HOST_OS),Linux)
HOST_LDFLAGS += \
	-Wl,--no-as-needed -lrt
endif

HOST_CONFIGURE_ARGS+= \
	--without-cxx-main \
	--without-pymalloc \
	--with-threads \
	--prefix=$(HOST_PYTHON3_DIR) \
	--exec-prefix=$(HOST_PYTHON3_DIR) \
	--with-system-expat=$(STAGING_DIR_HOSTPKG) \
	--with-ensurepip=install \
	CONFIG_SITE=

define Host/Compile
	+$(HOST_MAKE_VARS) $(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR) python Parser/pgen
	+$(HOST_MAKE_VARS) $(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR) sharedmods
endef

define Host/Install
	$(MAKE) -C $(HOST_BUILD_DIR) install
	$(INSTALL_DIR) $(HOST_PYTHON3_DIR)/bin/
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/Parser/pgen $(HOST_PYTHON3_DIR)/bin/pgen3
endef

$(eval $(call HostBuild))

$(foreach package, $(PYTHON3_PACKAGES),  \
	$(eval $(call Py3Package,$(package))) \
	$(eval $(call BuildPackage,$(package))) \
	$(eval $(call BuildPackage,$(package)-src)) \
)

$(eval $(call Py3Package,python3-base))
$(eval $(call Py3Package,python3-light))
$(eval $(call Py3Package,python3))

$(eval $(call BuildPackage,python3-base))
$(eval $(call BuildPackage,python3-light))
$(eval $(call BuildPackage,python3))

$(eval $(call BuildPackage,python3-base-src))
$(eval $(call BuildPackage,python3-light-src))
