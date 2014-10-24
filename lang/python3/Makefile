#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

# The file included below defines PYTHON_VERSION
include ./files/python3-package.mk

PYTHON_VERSION:=$(PYTHON3_VERSION)
PYTHON_VERSION_MICRO:=$(PYTHON3_VERSION_MICRO)

PKG_NAME:=python3
PKG_RELEASE:=1
PKG_VERSION:=$(PYTHON_VERSION).$(PYTHON_VERSION_MICRO)

PKG_SOURCE:=Python-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://www.python.org/ftp/python/$(PKG_VERSION)
PKG_MD5SUM:=6cafc183b4106476dd73d5738d7f616a

PKG_LICENSE:=PSF
PKG_LICENSE_FILES:=LICENSE Modules/_ctypes/libffi_msvc/LICENSE Modules/_ctypes/darwin/LICENSE Modules/_ctypes/libffi/LICENSE Modules/_ctypes/libffi_osx/LICENSE Tools/pybench/LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
HOST_BUILD_PARALLEL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/Python-$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/Python-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=python3/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/python3/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python $(PYTHON_VERSION) programming language
  URL:=http://www.python.org/
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

define Package/python3
$(call Package/python3/Default)
  DEPENDS:=+libpthread +zlib +libffi
endef

define Package/python3/description
$(call Package/python3/Default/description)
  .
  This package contains only the interpreter and the bare minimum for the interpreter to start.
endef

MAKE_FLAGS:=\
	$(TARGET_CONFIGURE_OPTS) \
	DESTDIR="$(PKG_INSTALL_DIR)" \
	CROSS_COMPILE=yes \
	CFLAGS="$(TARGET_CFLAGS) -DNDEBUG -fno-inline" \
	LDFLAGS="$(TARGET_LDFLAGS) -L$(PKG_BUILD_DIR)" \
	LD="$(TARGET_CC)"

ENABLE_IPV6:=
ifeq ($(CONFIG_IPV6),y)
	ENABLE_IPV6 += --enable-ipv6
endif

#=======================================================================
# Notes: adding these so that I don't forget, and can track why stuff
#        was did as was did
# - Arguments below were moved to ./files/config.site file, and disabled
#          ac_cv_have_chflags=no \
#          ac_cv_have_lchflags=no \
#          ac_cv_py_format_size_t=no \
#          ac_cv_have_long_long_format=yes \
#          ac_cv_buggy_getaddrinfo=no \
# - --without-ensurepip added, because the build wants to ensure that
#   it works; that's a good idea, but for now, it requires special 
#   setup, and we can do that later
# - --without-pymalloc added, becase in Python 3, modules are suffixed
#   with m; e.g. so some paths are python3.4m instead of python3.4 
#   all this is detailed here:
#     http://legacy.python.org/dev/peps/pep-3149/
#=======================================================================

define Build/Configure
	-$(MAKE) -C $(PKG_BUILD_DIR) distclean
	(cd $(PKG_BUILD_DIR); autoreconf --force --install || exit 0)
	$(CP) ./files/config.site $(PKG_BUILD_DIR)
	$(call Build/Configure/Default, \
		--sysconfdir=/etc \
		--enable-shared \
		--without-cxx-main \
		--with-threads \
		--with-system-ffi="$(STAGING_DIR)/usr" \
		--without-ensurepip \
		--without-pymalloc \
		$(ENABLE_IPV6) \
		CONFIG_SITE="$(PKG_BUILD_DIR)/config.site" \
		OPT="$(TARGET_CFLAGS)" \
	)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin $(1)/usr/bin $(1)/usr/include $(1)/usr/lib
	$(INSTALL_DIR) $(STAGING_DIR)/mk/
	$(INSTALL_DATA) ./files/python3-package.mk $(STAGING_DIR)/mk/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/python$(PYTHON_VERSION) \
		$(1)/usr/include/
	$(CP) \
		$(STAGING_DIR_HOST)/lib/python$(PYTHON_VERSION) \
		$(PKG_INSTALL_DIR)/usr/lib/libpython$(PYTHON_VERSION).so* \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON_VERSION)/config-$(PYTHON_VERSION) \
		$(1)/usr/lib/python$(PYTHON_VERSION)/

	$(CP) \
		$(STAGING_DIR_HOST)/bin/python$(PYTHON_VERSION)-config \
		$(2)/bin/
	$(SED) 's,^#!.*,#!/usr/bin/env python$(PYTHON_VERSION),g' $(2)/bin/python$(PYTHON_VERSION)-config
endef

define Py3Package/python3/filespec
+|/usr/bin/python$(PYTHON_VERSION)
+|/usr/lib/python$(PYTHON_VERSION)/encodings
+|/usr/lib/python$(PYTHON_VERSION)/_collections_abc.py
+|/usr/lib/python$(PYTHON_VERSION)/_sitebuiltins.py
+|/usr/lib/python$(PYTHON_VERSION)/_sysconfigdata.py
+|/usr/lib/python$(PYTHON_VERSION)/_weakrefset.py
+|/usr/lib/python$(PYTHON_VERSION)/abc.py
+|/usr/lib/python$(PYTHON_VERSION)/codecs.py
+|/usr/lib/python$(PYTHON_VERSION)/genericpath.py
+|/usr/lib/python$(PYTHON_VERSION)/io.py
+|/usr/lib/python$(PYTHON_VERSION)/os.py
+|/usr/lib/python$(PYTHON_VERSION)/posixpath.py
+|/usr/lib/python$(PYTHON_VERSION)/site.py
+|/usr/lib/python$(PYTHON_VERSION)/sysconfig.py
+|/usr/lib/python$(PYTHON_VERSION)/stat.py
endef

define Py3Package/python3/install
	# Adding the lib-dynload folder (even just empty) suppresses 2 warnings when starting Python
	$(INSTALL_DIR) $(1)/usr/lib/python$(PYTHON_VERSION)/lib-dynload/
	$(INSTALL_DIR) $(1)/usr/bin
	$(LN) python$(PYTHON_VERSION) $(1)/usr/bin/python3
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpython$(PYTHON_VERSION).so* $(1)/usr/lib/
endef

define Host/Configure
	-$(MAKE) -C $(HOST_BUILD_DIR) distclean
	(cd $(HOST_BUILD_DIR); autoreconf --force --install || exit 0)
	(cd $(HOST_BUILD_DIR); \
		rm -rf config.cache; \
		CONFIG_SITE= \
		OPT="$(HOST_CFLAGS)" \
		./configure \
			--without-cxx-main \
			--without-ensurepip \
			--without-pymalloc \
			--with-threads \
			--prefix=$(STAGING_DIR_HOST); \
	)
endef

define Host/Compile
	+$(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR) \
		python Parser/pgen
	+$(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR) \
		sharedmods
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOST)/bin/
	$(MAKE) -C $(HOST_BUILD_DIR) \
		install
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/Parser/pgen $(STAGING_DIR_HOST)/bin/
endef


$(eval $(call HostBuild))

$(eval $(call Py3Package,python3))

$(eval $(call BuildPackage,python3))
