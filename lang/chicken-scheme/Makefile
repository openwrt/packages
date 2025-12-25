# Copyright (C) 2019-2025, Jerônimo Pellegrini <j_p@aleph0.info>
#
# SPDX-License-Identifier: GPL-3.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=chicken-scheme
PKG_VERSION:=5.4.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/chicken-$(PKG_VERSION)
PKG_SOURCE:=chicken-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://code.call-cc.org/releases/$(PKG_VERSION)/
PKG_HASH:=3c5d4aa61c1167bf6d9bf9eaf891da7630ba9f5f3c15bf09515a7039bfcdec5f
PKG_MAINTAINER:=Jeronimo Pellegrini <j_p@aleph0.info>

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS += \
	C_COMPILER="$(TARGET_CC)" \
	C_COMPILER_OPTIMIZATION_OPTIONS="$(TARGET_CFLAGS)" \
	LINKER="$(TARGET_CC)" \
	PLATFORM=linux \
	PREFIX=/usr

SSTRIP:=$(STRIP)
STRIP:=:
RSTRIP:=:

define Package/chicken-scheme/Default
  TITLE:=Chicken Scheme
  SECTION:=lang
  CATEGORY:=Languages
  URL:=https://call-cc.org
endef

define Package/chicken-scheme/description/Default
  Chicken is an implementation of the Scheme language. It is portable,
  efficient, and supports the R5RS and R7RS (work in progress) standards, and
  many extensions.
  Chicken can be used as a scripting language to automate tasks.
  For more information, please refer to the Chicken Scheme website at
  https://call-cc.org.
endef

define Package/libchicken
$(call Package/chicken-scheme/Default)
  TITLE+= library
  ABI_VERSION:=11
endef

define Package/libchicken/description
$(call Package/chicken-scheme/description/Default)
  This package contains the library.
endef

define Package/chicken-scheme-interpreter
$(call Package/chicken-scheme/Default)
  TITLE+= interpreter only
  CONFLICTS:=chicken-scheme-full
  DEPENDS:=+libchicken
  EXTRA_DEPENDS:=libchicken (=$(PKG_VERSION)-r$(PKG_RELEASE))
endef

define Package/chicken-scheme-interpreter/description
$(call Package/chicken-scheme/description/Default)
  This package contains the interpreter, 'csi', only -- the compiler and the
  package installer are not included because they depend on a C compiler.
endef

# csc depends on gcc; chicken-install uses the 'install' command from coreutils
define Package/chicken-scheme-full
$(call Package/chicken-scheme/Default)
  TITLE+= full package
  DEPENDS:=+coreutils-install +gcc +libchicken
  EXTRA_DEPENDS:=libchicken (=$(PKG_VERSION)-r$(PKG_RELEASE))
endef

define Package/chicken-scheme-full/description
$(call Package/chicken-scheme/description/Default)
  This package contains the interpreter, 'csi'; the compiler, 'csc'; the tools
  for installing and removing eggs (modules); the profiler and the debugger.
  Note that this package depends on gcc, which is quite large (more than 100Mb).
endef

define Build/Compile
$(call Build/Compile/Default)
	$(SSTRIP) $(PKG_BUILD_DIR)/chicken
	$(SSTRIP) $(PKG_BUILD_DIR)/chicken-do
	$(SSTRIP) $(PKG_BUILD_DIR)/chicken-install
	$(SSTRIP) $(PKG_BUILD_DIR)/chicken-profile
	$(SSTRIP) $(PKG_BUILD_DIR)/chicken-status
	$(SSTRIP) $(PKG_BUILD_DIR)/chicken-uninstall
	$(SSTRIP) $(PKG_BUILD_DIR)/csc
	$(SSTRIP) $(PKG_BUILD_DIR)/csi
endef

define Package/libchicken/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libchicken.so{,.$(ABI_VERSION)} $(1)/usr/lib

	$(INSTALL_DIR) $(1)/usr/lib/chicken/$(ABI_VERSION)
	$(CP) $(PKG_BUILD_DIR)/*.import.so $(1)/usr/lib/chicken/$(ABI_VERSION)
	$(CP) $(PKG_BUILD_DIR)/types.db $(1)/usr/lib/chicken/$(ABI_VERSION)
endef

define Package/chicken-scheme-interpreter/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/csi $(1)/usr/bin
endef

define Package/chicken-scheme-full/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chicken $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chicken-do $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chicken-install $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chicken-profile $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chicken-status $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chicken-uninstall $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/csc $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/csi $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/feathers $(1)/usr/bin

	$(INSTALL_DIR) $(1)/usr/include/chicken
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/chicken.h $(1)/usr/include/chicken
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/chicken-config.h $(1)/usr/include/chicken

	$(INSTALL_DIR) $(1)/usr/share/chicken
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/feathers.tcl $(1)/usr/share/chicken
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/setup.defaults $(1)/usr/share/chicken
endef

$(eval $(call BuildPackage,chicken-scheme-full))
$(eval $(call BuildPackage,chicken-scheme-interpreter))
$(eval $(call BuildPackage,libchicken))
