#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python
PKG_VERSION:=2.7.3
PKG_RELEASE:=2

PKG_SOURCE:=Python-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://www.python.org/ftp/python/$(PKG_VERSION)
PKG_MD5SUM:=62c4c1699170078c469f79ddfed21bc0

PKG_LICENSE:=PSF
PKG_LICENSE_FILES:=LICENSE Modules/_ctypes/libffi_msvc/LICENSE Modules/_ctypes/darwin/LICENSE Modules/_ctypes/libffi/LICENSE Modules/_ctypes/libffi_osx/LICENSE Tools/pybench/LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
HOST_BUILD_PARALLEL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/Python-$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/Python-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=python/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
-include $(if $(DUMP),,./files/python-package.mk)

define Package/python/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python $(PYTHON_VERSION) programming language
  URL:=http://www.python.org/
endef

define Package/python/Default/description
 Python is a dynamic object-oriented programming language that can be used
 for many kinds of software development. It offers strong support for
 integration with other languages and tools, comes with extensive standard
 libraries, and can be learned in a few days. Many Python programmers
 report substantial productivity gains and feel the language encourages
 the development of higher quality, more maintainable code.
endef

define Package/python
$(call Package/python/Default)
  TITLE+= (full)
  DEPENDS:=+libpthread +zlib +libffi +python-mini
endef

define Package/python/description
$(call Package/python/Default/description)
 .
 This package contains the full Python install.
endef

define Package/python-mini
$(call Package/python/Default)
  TITLE+= (minimal)
  DEPENDS:=+libpthread +zlib
endef

define Package/python-mini/description
$(call Package/python/Default/description)
  .
  This package contains only a minimal Python install.
endef

define Package/python-doc
$(call Package/python/Default)
  TITLE:=Python interactive documentation
  DEPENDS+=+python-mini
endef

define Package/python-bzip2
$(call Package/python/Default)
  TITLE:=Python support for Bzip2
  DEPENDS+=+python-mini +libbz2
endef

define Package/python-expat
$(call Package/python/Default)
  TITLE:=Python support for expat
  DEPENDS+=+python-mini +libexpat
endef

define Package/python-gzip
$(call Package/python/Default)
  TITLE:=Python support for gzip
  DEPENDS+=+python-mini
endef

define Package/python-openssl
$(call Package/python/Default)
 TITLE:=Python support for OpenSSL
 DEPENDS+=+python-mini +libopenssl
endef

define Package/python-shutil
$(call Package/python/Default)
  TITLE:=Python support for shutil
  DEPENDS+=+python-mini
endef

# Needs datetime
define Package/python-sqlite3
$(call Package/python/Default)
 TITLE:=Python support for sqlite3
 DEPENDS+=+python +libsqlite3
endef

define Package/python-gdbm
$(call Package/python/Default)
 TITLE:=Python support for gdbm
 DEPENDS+=+python-mini +libgdbm
endef

define Package/python-readline
$(call Package/python/Default)
 TITLE:=Python support for readline
 DEPENDS+=+python-mini +libreadline +libncurses @BROKEN
endef

define Package/python-ncurses
$(call Package/python/Default)
 TITLE:=Python support for readline
 DEPENDS+=+python-mini +libncurses
endef

MAKE_FLAGS:=\
	$(TARGET_CONFIGURE_OPTS) \
	DESTDIR="$(PKG_INSTALL_DIR)" \
	CROSS_COMPILE=yes \
	CFLAGS="$(TARGET_CFLAGS) -DNDEBUG -fno-inline" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	LD="$(TARGET_CC)" \
	HOSTPYTHON=./hostpython \
	HOSTPGEN=./hostpgen

ENABLE_IPV6:=
ifeq ($(CONFIG_IPV6),y)
	ENABLE_IPV6 += --enable-ipv6
endif

define Build/Configure
	-$(MAKE) -C $(PKG_BUILD_DIR) distclean
	(cd $(PKG_BUILD_DIR); autoreconf --force --install || exit 0)
	# The python executable needs to stay in the rootdir since its location will
	# be used to compute the path of the config files.
	$(CP) $(STAGING_DIR_HOST)/bin/pgen $(PKG_BUILD_DIR)/hostpgen
	$(CP) $(STAGING_DIR_HOST)/bin/python$(PYTHON_VERSION) $(PKG_BUILD_DIR)/hostpython
	$(call Build/Configure/Default, \
		--sysconfdir=/etc \
		--disable-shared \
		--without-cxx-main \
		--with-threads \
		--with-system-ffi="$(STAGING_DIR)/usr" \
		$(ENABLE_IPV6) \
		ac_cv_have_chflags=no \
		ac_cv_have_lchflags=no \
		ac_cv_py_format_size_t=no \
		ac_cv_have_long_long_format=yes \
		ac_cv_buggy_getaddrinfo=no \
		OPT="$(TARGET_CFLAGS)" \
	)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin $(1)/usr/bin $(1)/usr/include $(1)/usr/lib
	$(INSTALL_DIR) $(STAGING_DIR)/mk/
	$(INSTALL_DATA) ./files/python-package.mk $(STAGING_DIR)/mk/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/python$(PYTHON_VERSION) \
		$(1)/usr/include/
	$(CP) \
		$(STAGING_DIR_HOST)/lib/python$(PYTHON_VERSION) \
		$(PKG_BUILD_DIR)/libpython$(PYTHON_VERSION).a \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON_VERSION)/config \
		$(1)/usr/lib/python$(PYTHON_VERSION)/

	$(CP) \
		$(STAGING_DIR_HOST)/bin/python$(PYTHON_VERSION) \
		$(1)/usr/bin/hostpython
	(cd $(2)/bin; \
	ln -sf ../../usr/bin/hostpython python$(PYTHON_VERSION); \
	ln -sf python$(PYTHON_VERSION) python)

	$(CP) \
		$(STAGING_DIR_HOST)/bin/python$(PYTHON_VERSION)-config \
		$(2)/bin/
	$(SED) 's,^#!.*,#!/usr/bin/env python$(PYTHON_VERSION),g' $(2)/bin/python$(PYTHON_VERSION)-config

	(cd $(2)/bin; \
	ln -sf python$(PYTHON_VERSION)-config python-config;)
endef

define PyPackage/python/filespec
+|/usr/lib/python$(PYTHON_VERSION)
-|/usr/lib/python$(PYTHON_VERSION)/bsddb/test
-|/usr/lib/python$(PYTHON_VERSION)/config
-|/usr/lib/python$(PYTHON_VERSION)/ctypes/test
-|/usr/lib/python$(PYTHON_VERSION)/distutils/command/wininst-*.exe
-|/usr/lib/python$(PYTHON_VERSION)/distutils/tests
-|/usr/lib/python$(PYTHON_VERSION)/email/test
-|/usr/lib/python$(PYTHON_VERSION)/idlelib
-|/usr/lib/python$(PYTHON_VERSION)/json/tests
-|/usr/lib/python$(PYTHON_VERSION)/lib-tk
-|/usr/lib/python$(PYTHON_VERSION)/sqlite3
-|/usr/lib/python$(PYTHON_VERSION)/test
-|/usr/lib/python$(PYTHON_VERSION)/lib2to3
-|/usr/lib/python$(PYTHON_VERSION)/lib-old
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/bz2.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/gdbm.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_sqlite3.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_ssl.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/pyexpat.so
-|/usr/lib/python$(PYTHON_VERSION)/pydoc_data
-|/usr/lib/python$(PYTHON_VERSION)/pydoc.py
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_ctypes_test.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_testcapi.so
-|/usr/lib/python$(PYTHON_VERSION)/__future__.py
-|/usr/lib/python$(PYTHON_VERSION)/_abcoll.py
-|/usr/lib/python$(PYTHON_VERSION)/abc.py
-|/usr/lib/python$(PYTHON_VERSION)/codecs.py
-|/usr/lib/python$(PYTHON_VERSION)/compileall.py
-|/usr/lib/python$(PYTHON_VERSION)/ConfigParser.py
-|/usr/lib/python$(PYTHON_VERSION)/copy.py
-|/usr/lib/python$(PYTHON_VERSION)/copy_reg.py
-|/usr/lib/python$(PYTHON_VERSION)/dis.py
-|/usr/lib/python$(PYTHON_VERSION)/encodings
-|/usr/lib/python$(PYTHON_VERSION)/fnmatch.py
-|/usr/lib/python$(PYTHON_VERSION)/genericpath.py
-|/usr/lib/python$(PYTHON_VERSION)/getopt.py
-|/usr/lib/python$(PYTHON_VERSION)/glob.py
-|/usr/lib/python$(PYTHON_VERSION)/hashlib.py
-|/usr/lib/python$(PYTHON_VERSION)/inspect.py
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/array.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/binascii.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/cStringIO.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_curses.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_curses_panel.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/dbm.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_bsddb.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/fcntl.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/grp.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/itertools.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/math.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_md5.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/operator.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_random.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/readline.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/select.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_sha.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_sha256.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_sha512.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_socket.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/strop.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_struct.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/syslog.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/time.so
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/unicodedata.so
-|/usr/lib/python$(PYTHON_VERSION)/linecache.py
-|/usr/lib/python$(PYTHON_VERSION)/md5.py
-|/usr/lib/python$(PYTHON_VERSION)/new.py
-|/usr/lib/python$(PYTHON_VERSION)/opcode.py
-|/usr/lib/python$(PYTHON_VERSION)/optparse.py
-|/usr/lib/python$(PYTHON_VERSION)/os.py
-|/usr/lib/python$(PYTHON_VERSION)/pickle.py
-|/usr/lib/python$(PYTHON_VERSION)/pickle.py
-|/usr/lib/python$(PYTHON_VERSION)/pkgutil.py
-|/usr/lib/python$(PYTHON_VERSION)/popen2.py
-|/usr/lib/python$(PYTHON_VERSION)/posixpath.py
-|/usr/lib/python$(PYTHON_VERSION)/py_compile.py
-|/usr/lib/python$(PYTHON_VERSION)/random.py
-|/usr/lib/python$(PYTHON_VERSION)/repr.py
-|/usr/lib/python$(PYTHON_VERSION)/re.py
-|/usr/lib/python$(PYTHON_VERSION)/sha.py
-|/usr/lib/python$(PYTHON_VERSION)/site.py
-|/usr/lib/python$(PYTHON_VERSION)/socket.py
-|/usr/lib/python$(PYTHON_VERSION)/sre_compile.py
-|/usr/lib/python$(PYTHON_VERSION)/sre_constants.py
-|/usr/lib/python$(PYTHON_VERSION)/sre_parse.py
-|/usr/lib/python$(PYTHON_VERSION)/sre.py
-|/usr/lib/python$(PYTHON_VERSION)/stat.py
-|/usr/lib/python$(PYTHON_VERSION)/StringIO.py
-|/usr/lib/python$(PYTHON_VERSION)/stringprep.py
-|/usr/lib/python$(PYTHON_VERSION)/string.py
-|/usr/lib/python$(PYTHON_VERSION)/struct.py
-|/usr/lib/python$(PYTHON_VERSION)/subprocess.py
-|/usr/lib/python$(PYTHON_VERSION)/tempfile.py
-|/usr/lib/python$(PYTHON_VERSION)/textwrap.py
-|/usr/lib/python$(PYTHON_VERSION)/tokenize.py
-|/usr/lib/python$(PYTHON_VERSION)/token.py
-|/usr/lib/python$(PYTHON_VERSION)/traceback.py
-|/usr/lib/python$(PYTHON_VERSION)/types.py
-|/usr/lib/python$(PYTHON_VERSION)/UserDict.py
-|/usr/lib/python$(PYTHON_VERSION)/warnings.py
-|/usr/lib/python$(PYTHON_VERSION)/weakref.py
-|/usr/lib/python$(PYTHON_VERSION)/_weakrefset.py
-|/usr/lib/python$(PYTHON_VERSION)/sysconfig.py
-|/usr/lib/python$(PYTHON_VERSION)/functools.py
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_functools.so
-|/usr/lib/python$(PYTHON_VERSION)/collections.py
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_collections.so
-|/usr/lib/python$(PYTHON_VERSION)/keyword.py
-|/usr/lib/python$(PYTHON_VERSION)/heapq.py
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_heapq.so
-|/usr/lib/python$(PYTHON_VERSION)/bisect.py
-|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_bisect.so
endef

define PyPackage/python-mini/filespec
+|/usr/bin/python$(PYTHON_VERSION)
+|/usr/lib/python$(PYTHON_VERSION)/__future__.py
+|/usr/lib/python$(PYTHON_VERSION)/_abcoll.py
+|/usr/lib/python$(PYTHON_VERSION)/abc.py
+|/usr/lib/python$(PYTHON_VERSION)/codecs.py
+|/usr/lib/python$(PYTHON_VERSION)/compileall.py
+|/usr/lib/python$(PYTHON_VERSION)/ConfigParser.py
+|/usr/lib/python$(PYTHON_VERSION)/copy.py
+|/usr/lib/python$(PYTHON_VERSION)/copy_reg.py
+|/usr/lib/python$(PYTHON_VERSION)/dis.py
+|/usr/lib/python$(PYTHON_VERSION)/encodings
+|/usr/lib/python$(PYTHON_VERSION)/fnmatch.py
+|/usr/lib/python$(PYTHON_VERSION)/genericpath.py
+|/usr/lib/python$(PYTHON_VERSION)/getopt.py
+|/usr/lib/python$(PYTHON_VERSION)/glob.py
+|/usr/lib/python$(PYTHON_VERSION)/hashlib.py
+|/usr/lib/python$(PYTHON_VERSION)/inspect.py
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/array.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/binascii.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/cStringIO.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/fcntl.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/grp.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/itertools.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/math.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_md5.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/operator.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_random.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/select.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_sha.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_sha256.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_sha512.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_socket.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/strop.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_struct.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/syslog.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/time.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/unicodedata.so
+|/usr/lib/python$(PYTHON_VERSION)/linecache.py
+|/usr/lib/python$(PYTHON_VERSION)/md5.py
+|/usr/lib/python$(PYTHON_VERSION)/new.py
+|/usr/lib/python$(PYTHON_VERSION)/opcode.py
+|/usr/lib/python$(PYTHON_VERSION)/optparse.py
+|/usr/lib/python$(PYTHON_VERSION)/os.py
+|/usr/lib/python$(PYTHON_VERSION)/pickle.py
+|/usr/lib/python$(PYTHON_VERSION)/pickle.py
+|/usr/lib/python$(PYTHON_VERSION)/pkgutil.py
+|/usr/lib/python$(PYTHON_VERSION)/popen2.py
+|/usr/lib/python$(PYTHON_VERSION)/posixpath.py
+|/usr/lib/python$(PYTHON_VERSION)/py_compile.py
+|/usr/lib/python$(PYTHON_VERSION)/random.py
+|/usr/lib/python$(PYTHON_VERSION)/repr.py
+|/usr/lib/python$(PYTHON_VERSION)/re.py
+|/usr/lib/python$(PYTHON_VERSION)/sha.py
+|/usr/lib/python$(PYTHON_VERSION)/site.py
+|/usr/lib/python$(PYTHON_VERSION)/socket.py
+|/usr/lib/python$(PYTHON_VERSION)/sre_compile.py
+|/usr/lib/python$(PYTHON_VERSION)/sre_constants.py
+|/usr/lib/python$(PYTHON_VERSION)/sre_parse.py
+|/usr/lib/python$(PYTHON_VERSION)/sre.py
+|/usr/lib/python$(PYTHON_VERSION)/stat.py
+|/usr/lib/python$(PYTHON_VERSION)/StringIO.py
+|/usr/lib/python$(PYTHON_VERSION)/stringprep.py
+|/usr/lib/python$(PYTHON_VERSION)/string.py
+|/usr/lib/python$(PYTHON_VERSION)/struct.py
+|/usr/lib/python$(PYTHON_VERSION)/subprocess.py
+|/usr/lib/python$(PYTHON_VERSION)/tempfile.py
+|/usr/lib/python$(PYTHON_VERSION)/textwrap.py
+|/usr/lib/python$(PYTHON_VERSION)/tokenize.py
+|/usr/lib/python$(PYTHON_VERSION)/token.py
+|/usr/lib/python$(PYTHON_VERSION)/traceback.py
+|/usr/lib/python$(PYTHON_VERSION)/types.py
+|/usr/lib/python$(PYTHON_VERSION)/UserDict.py
+|/usr/lib/python$(PYTHON_VERSION)/warnings.py
+|/usr/lib/python$(PYTHON_VERSION)/weakref.py
+|/usr/lib/python$(PYTHON_VERSION)/_weakrefset.py
+|/usr/lib/python$(PYTHON_VERSION)/config/Makefile
+|/usr/lib/python$(PYTHON_VERSION)/sysconfig.py
+|/usr/lib/python$(PYTHON_VERSION)/functools.py
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_functools.so
+|/usr/lib/python$(PYTHON_VERSION)/collections.py
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_collections.so
+|/usr/lib/python$(PYTHON_VERSION)/keyword.py
+|/usr/lib/python$(PYTHON_VERSION)/heapq.py
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_heapq.so
+|/usr/lib/python$(PYTHON_VERSION)/bisect.py
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_bisect.so
+|/usr/include/python$(PYTHON_VERSION)/pyconfig.h
endef

define PyPackage/python-mini/install
	ln -sf python$(PYTHON_VERSION) $(1)/usr/bin/python
endef

define PyPackage/python-doc/filespec
+|/usr/lib/python$(PYTHON_VERSION)/pydoc_data
+|/usr/lib/python$(PYTHON_VERSION)/pydoc.py
endef

define PyPackage/python-bzip2/filespec
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/bz2.so
endef

define PyPackage/python-expat/filespec
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/pyexpat.so
endef

define PyPackage/python-gzip/filespec
+|/usr/lib/python$(PYTHON_VERSION)/gzip.py
endef

define PyPackage/python-openssl/filespec
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_ssl.so
endef

define PyPackage/python-shutil/filespec
+|/usr/lib/python$(PYTHON_VERSION)/shutil.py
endef

define PyPackage/python-sqlite3/filespec
+|/usr/lib/python$(PYTHON_VERSION)/sqlite3
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_sqlite3.so
endef

define PyPackage/python-gdbm/filespec
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/gdbm.so
endef

define PyPackage/python-readline/filespec
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/readline.so
endef

define PyPackage/python-ncurses/filespec
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_curses.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_curses_panel.so
endef

define Host/Configure
	-$(MAKE) -C $(HOST_BUILD_DIR) distclean
	(cd $(HOST_BUILD_DIR); autoreconf --force --install || exit 0)
	(cd $(HOST_BUILD_DIR); \
		rm -rf config.cache; \
		CONFIG_SITE= \
		OPT="$(HOST_CFLAGS)" \
		./configure --without-cxx-main --with-threads --prefix=$(STAGING_DIR_HOST); \
	)
endef

define Host/Compile
	+$(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR) \
		python Parser/pgen
	+$(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR) \
		HOSTPYTHON=$(HOST_BUILD_DIR)/python \
		sharedmods
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOST)/bin/
	$(MAKE) -C $(HOST_BUILD_DIR) \
		HOSTPYTHON=$(HOST_BUILD_DIR)/python \
		install
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/Parser/pgen $(STAGING_DIR_HOST)/bin/
endef


$(eval $(call HostBuild))

$(eval $(call PyPackage,python))
$(eval $(call PyPackage,python-mini))
$(eval $(call PyPackage,python-doc))
$(eval $(call PyPackage,python-bzip2))
$(eval $(call PyPackage,python-expat))
$(eval $(call PyPackage,python-gzip))
$(eval $(call PyPackage,python-openssl))
$(eval $(call PyPackage,python-shutil))
$(eval $(call PyPackage,python-sqlite3))
$(eval $(call PyPackage,python-gdbm))
$(eval $(call PyPackage,python-readline))
$(eval $(call PyPackage,python-ncurses))

$(eval $(call BuildPackage,python))
$(eval $(call BuildPackage,python-mini))
$(eval $(call BuildPackage,python-doc))
$(eval $(call BuildPackage,python-bzip2))
$(eval $(call BuildPackage,python-expat))
$(eval $(call BuildPackage,python-gzip))
$(eval $(call BuildPackage,python-openssl))
$(eval $(call BuildPackage,python-shutil))
$(eval $(call BuildPackage,python-sqlite3))
$(eval $(call BuildPackage,python-gdbm))
$(eval $(call BuildPackage,python-readline))
$(eval $(call BuildPackage,python-ncurses))
