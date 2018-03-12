#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=talloc
PKG_VERSION:=2.1.11
MAJOR_VERSION:=2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.samba.org/ftp/talloc/
PKG_HASH:=639eb35556a0af999123c4d883e79be05ff9f00ab4f9e4ac2e5775f9c5eeeed3

PKG_MAINTAINER:=Lucile Quirion <lucile.quirion@savoirfairelinux.com>
PKG_LICENSE:=LGPL-3.0+

PKG_BUILD_PARALLEL:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/libtalloc
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Core memory allocator used in Samba
  DEPENDS:=+USE_GLIBC:libbsd $(ICONV_DEPENDS) +libattr
  URL:=https://talloc.samba.org/talloc/doc/html/index.html
endef

define Package/libtalloc/description
  talloc is a hierarchical, reference counted memory pool system with destructors.
endef

CROSS = " \
	\nChecking simple C program: OK \
	\nrpath library support: OK \
	\n-Wl,--version-script support: OK \
	\nChecking getconf LFS_CFLAGS: NO \
	\nChecking for large file support without additional flags: OK \
	\nChecking for -D_LARGE_FILES: OK \
	\nChecking correct behavior of strtoll: NO \
	\nChecking for working strptime: OK \
	\nChecking for C99 vsnprintf: OK \
	\nChecking for HAVE_SHARED_MMAP: OK \
	\nChecking for HAVE_MREMAP: OK \
	\nChecking for HAVE_INCOHERENT_MMAP: NO \
	\nChecking for HAVE_SECURE_MKSTEMP: OK \
	\nChecking for HAVE_IFACE_GETIFADDRS: OK \
	\nChecking for kernel change notify support: OK \
	\nChecking for Linux kernel oplocks: OK \
	\nChecking for kernel share modes: OK \
	\nChecking if can we convert from CP850 to UCS-2LE: OK \
	\nChecking if can we convert from UTF-8 to UCS-2LE: OK \
	\nChecking whether we can use Linux thread-specific credentials with 32-bit system calls: OK \
	\nChecking whether we can use Linux thread-specific credentials: OK \
	\nChecking whether setreuid is available: OK \
	\nChecking whether setresuid is available: OK \
	\nChecking whether seteuid is available: OK \
	\nChecking whether fcntl locking is available: OK \
	\nChecking for the maximum value of the 'time_t' type: OK \
	\nChecking whether the realpath function allows a NULL argument: OK \
	\nChecking whether POSIX capabilities are available: OK \
	\nChecking for ftruncate extend: OK \
	\nvfs_fileid checking for statfs() and struct statfs.f_fsid: OK \
	\ngetcwd takes a NULL argument: OK \
	\nChecking value of NSIG: \"65\" \
	\nChecking value of _NSIG: \"65\" \
	\nChecking value of SIGRTMAX: \"64\" \
	\nChecking value of SIGRTMIN: \"34\" \
	\nChecking if toolchain accepts -fstack-protector: OK \
	\n"

define Build/Configure
	(cd $(PKG_BUILD_DIR); \
		echo -e >cache.txt $(CROSS) " \
			\nChecking uname machine type: \"$(ARCH)\" \
			\nChecking uname release type: \"$(LINUX_VERSION)\" \
			\nChecking uname sysname type: \"Linux\" \
			\nChecking uname version type: \"$(LINUX_UNAME_VERSION)\" \
		\n" ; \
		$(CONFIGURE_VARS) \
		./buildtools/bin/waf configure \
			--prefix=/usr \
			--sysconfdir=/etc \
			--localstatedir=/var \
			--with-libiconv="$(ICONV_PREFIX)" \
			--cross-compile \
			--cross-answers=$(PKG_BUILD_DIR)/cache.txt \
			--disable-rpath \
			--disable-rpath-install \
	)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/bin/default/libtalloc.so $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/bin/default/talloc.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libtalloc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/bin/default/libtalloc.so $(1)/usr/lib/libtalloc.so.$(MAJOR_VERSION)
	(cd $(1)/usr/lib; ln -sf libtalloc.so.$(MAJOR_VERSION) libtalloc.so)
endef

$(eval $(call BuildPackage,libtalloc))
