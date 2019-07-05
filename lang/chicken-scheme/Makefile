#
# Copyright (C) 2019 Jerônimo Cordoni Pellegrini <j_p@aleph0.info>
#
# This file is free software, licensed under the GNU General Public License v3
# or later.
# See /LICENSE for details
#

include $(TOPDIR)/rules.mk

PKG_NAME:=chicken-scheme-interpreter
PKG_VERSION=5.1.0
PKG_RELEASE:=1

PKG_SOURCE:=chicken-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://code.call-cc.org/releases/$(PKG_VERSION)/
PKG_HASH:=5c1101a8d8faabfd500ad69101e0c7c8bd826c68970f89c270640470e7b84b4b
PKG_BUILD_DIR:=$(BUILD_DIR)/chicken-$(PKG_VERSION)

PKG_MAINTAINER:=Jeronimo Pellegrini <j_p@aleph0.info>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/chicken-scheme-interpreter
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Chicken Scheme
  URL:=https://call-cc.org
  ABI_VERSION:=11
endef

define Package/chicken-scheme-interpreter/description
  Chicken is an implementation of the Scheme language. It is portable, efficient, and supports 
  the R5RS and R7RS (work in progress) standards, and many extensions.
  Chicken can be used as a scripting language to automate tasks.
  This package contains the interpreter, 'csi', only --
  the compiler and the package installer are not included because they depend on a C compiler.
  For more information, please refer to the Chicken Scheme website at https://call-cc.org.
endef

MAKE_FLAGS += PLATFORM=linux C_COMPILER=$(TARGET_CC) LINKER=$(TARGET_CC) PREFIX=/usr C_COMPILER_OPTIMIZATION_OPTIONS="$(TARGET_CFLAGS)"

# not installed:
# - csc and chicken, the compiler
# - the include dir (only useful with the compiler)
# - install, uninstall, status, and chicken-do, which deal with modules (installation of more modules depends on the compiler)
# - profiler
# - feathers, the debugger
# - libchicken.a, the static library
define Package/chicken-scheme-interpreter/install
	$(INSTALL_DIR)  $(1)/usr/bin
	$(INSTALL_DIR)  $(1)/usr/lib/chicken/$(ABI_VERSION)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/csi                 $(1)/usr/bin/
	$(CP) $(PKG_BUILD_DIR)/libchicken.so.$(ABI_VERSION) $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libchicken.so                $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/*.import.so                  $(1)/usr/lib/chicken/$(ABI_VERSION)/
	$(CP) $(PKG_BUILD_DIR)/types.db                     $(1)/usr/lib/chicken/$(ABI_VERSION)/
endef

$(eval $(call BuildPackage,chicken-scheme-interpreter))

