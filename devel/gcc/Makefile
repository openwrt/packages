#
# Copyright (C) 2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#
# NB: GCC building is a bit special, you need to have the gcc build-deps installed on the build machine as well,
#     for instance mpfr, mpc and gmp development packages!
#
include $(TOPDIR)/rules.mk
PKG_NAME:=gcc
PKG_VERSION:=linaro-4.6-2013.05
PKG_RELEASE:=1
PKG_SOURCE_URL:=https://releases.linaro.org/13.05/components/toolchain/gcc-linaro/4.6/
PKG_SOURCE:=gcc-$(PKG_VERSION).tar.bz2
PKG_MD5SUM:=26b48802ae1203cd99415026fbf56ed7

include $(INCLUDE_DIR)/package.mk

SEP:=,
TARGET_LANGUAGES:="c$(if $(CONFIG_INSTALL_LIBSTDCPP),$(SEP)c++)$(if $(CONFIG_INSTALL_LIBGCJ),$(SEP)java)"
EXTRA_TARGET=$(if $(CONFIG_EXTRA_TARGET_ARCH),--enable-biarch --enable-targets=$(call qstrip,$(CONFIG_EXTRA_TARGET_ARCH_NAME))-linux-uclibc)

define Package/gcc
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=gcc
  MAINTAINER:=Christian Beier <cb@shoutrlabs.com>
  DEPENDS:=@TARGET_x86 @NO_STRIP
endef

define Package/gcc/description
	build a native toolchain for compiling on target
endef

define Build/Prepare
	$(PKG_UNPACK)
# 	we have to download additional stuff before patching
	(cd $(PKG_BUILD_DIR) && ./contrib/download_prerequisites)
	$(Build/Patch)
	$(SED) 's,\(version_string.. = "[0-9\.]*\).*\(";\),\1 (OpenWrt-2.0)\2,' $(PKG_BUILD_DIR)/gcc/version.c
	$(SED) 's,\(bug_report_url.. = "\).*\(";\),\1<URL:https://dev.openwrt.org/>\2,' $(PKG_BUILD_DIR)/gcc/version.c
endef


define Build/Configure
	(cd $(PKG_BUILD_DIR); rm -f config.cache; \
		SHELL="$(BASH)" \
		$(TARGET_CONFIGURE_OPTS) \
		$(PKG_BUILD_DIR)/configure \
			$(CONFIGURE_ARGS) \
			--enable-languages=$(TARGET_LANGUAGES) \
			--disable-__cxa_atexit \
			--enable-target-optspace \
			--with-gnu-ld \
			--disable-nls \
			--disable-libmudflap \
			--disable-multilib \
			--disable-libgomp \
			--disable-libquadmath \
			--disable-decimal-float \
			--with-host-libstdcxx=-lstdc++ \
			--disable-libstdcxx-pch \
			$(EXTRA_TARGET) \
			$(SOFT_FLOAT_CONFIG_OPTION) \
			$(call qstrip,$(CONFIG_EXTRA_GCC_CONFIG_OPTIONS)) \
			$(if $(CONFIG_mips64)$(CONFIG_mips64el),--with-arch=mips64 \
			--with-abi=$(subst ",,$(CONFIG_MIPS64_ABI))) \
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
