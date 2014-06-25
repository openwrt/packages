#
# Copyright (C) 2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
PKG_NAME:=gcc
PKG_VERSION:=$(strip $(subst ",, $(CONFIG_GCC_VERSION)))#"))
PKG_RELEASE:=1
PATCH_DIR=$(TOPDIR)/toolchain/gcc/patches/$(PKG_VERSION)
PKG_SOURCE_URL:=ftp://ftp.fu-berlin.de/unix/languages/gcc/releases/gcc-$(PKG_VERSION) \
    http://mirrors.rcn.net/pub/sourceware/gcc/releases/gcc-$(PKG_VERSION) \
	    ftp://ftp.gnu.org/gnu/gcc/releases/gcc-$(PKG_VERSION)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_MD5SUM:=354853e0b2da90c527e35aabb8d6f1e6

include $(INCLUDE_DIR)/package.mk

SEP:=,
TARGET_LANGUAGES:="c$(if $(CONFIG_INSTALL_LIBSTDCPP),$(SEP)c++)$(if $(CONFIG_INSTALL_LIBGCJ),$(SEP)java)"
EXTRA_TARGET=$(if $(CONFIG_EXTRA_TARGET_ARCH),--enable-biarch --enable-targets=$(call qstrip,$(CONFIG_EXTRA_TARGET_ARCH_NAME))-linux-uclibc)

define Package/gcc
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=gcc
  DEPENDS:=@TARGET_x86 @NO_STRIP
endef

define Package/gcc/description
	build a native toolchain for compiling on target
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(SED) 's,\(version_string.. = "[0-9\.]*\).*\(";\),\1 (OpenWrt-2.0)\2,' $(PKG_BUILD_DIR)/gcc/version.c
	$(SED) 's,\(bug_report_url.. = "\).*\(";\),\1<URL:https://dev.openwrt.org/>\2,' $(PKG_BUILD_DIR)/gcc/version.c
	(cd $(PKG_BUILD_DIR)/libstdc++-v3; autoconf;);
	$(SED) 's,gcc_no_link=yes,gcc_no_link=no,' $(PKG_BUILD_DIR)/libstdc++-v3/configure
endef

define Build/Configure
	(cd $(PKG_BUILD_DIR); rm -f config.cache; \
		SHELL="$(BASH)" \
		$(TARGET_CONFIGURE_OPTS) \
		$(PKG_BUILD_DIR)/configure \
			$(TARGET_CONFIGURE_ARGS) \
			--build=$(GNU_HOST_NAME) \
			--host=$(REAL_GNU_TARGET_NAME) \
			--target=$(REAL_GNU_TARGET_NAME) \
			--enable-languages=$(TARGET_LANGUAGES) \
			--enable-shared \
			--disable-__cxa_atexit \
			--enable-target-optspace \
			--with-gnu-ld \
			--disable-nls \
			--disable-libmudflap \
			--disable-multilib \
			$(EXTRA_TARGET) \
			$(SOFT_FLOAT_CONFIG_OPTION) \
			$(call qstrip,$(CONFIG_EXTRA_GCC_CONFIG_OPTIONS)) \
	);
endef

define Build/Compile
	export SHELL="$(BASH)"; $(MAKE_VARS) $(MAKE) -C $(PKG_BUILD_DIR) \
			DESTDIR="$(PKG_INSTALL_DIR)" $(MAKE_ARGS) all install
	# Set up the symlinks to enable lying about target name.
	set -e; \
	(cd $(TOOLCHAIN_DIR); \
		ln -sf $(REAL_GNU_TARGET_NAME) $(GNU_TARGET_NAME); \
		cd bin; \
		for app in $(REAL_GNU_TARGET_NAME)-* ; do \
			ln -sf $$$${app} \
			$(GNU_TARGET_NAME)$$$${app##$(REAL_GNU_TARGET_NAME)}; \
		done; \
	);
endef

define Package/gcc/install
	$(INSTALL_DIR) $(1)/usr/lib/
	cp -r $(PKG_INSTALL_DIR)/* $(1)
	cp -r $(TOOLCHAIN_DIR)/include $(1)/usr/
	cp $(TOOLCHAIN_DIR)/lib/crt* $(1)/usr/lib/
	cp $(TOOLCHAIN_DIR)/lib/libc.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,gcc))
