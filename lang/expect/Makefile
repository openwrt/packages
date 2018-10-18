#
# Copyright (C) 2006-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=expect
PKG_VERSION:=5.45.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_HASH:=49a7da83b0bdd9f46d04a04deec19c7767bb9a323e40c4781f89caf760b92c34
PKG_MAINTAINER:=Vadim Radovel <vadim@radovel.ru>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)$(PKG_VERSION)
PKG_BUILD_DEPENDS:=tcl/host

# prevent "autoreconf" from removing "aclocal.m4"
PKG_REMOVE_FILES:=
PKG_CHECK_FORMAT_SECURITY:=0
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/expect
	SUBMENU:=Tcl
	SECTION:=lang
	CATEGORY:=Languages
	DEPENDS:=tcl
	TITLE:=Expect library
	URL:=https://core.tcl.tk/expect/
endef

define Package/expect/description
Expect, a program that performs programmed dialogue with other interactive programs.
endef

MAKE_INSTALL_FLAGS += \
	TCLSH=$(STAGING_DIR_HOSTPKG)/bin/tclsh


define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
endef

define Package/expect/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/lib/$(PKG_NAME)$(PKG_VERSION)
	$(INSTALL_DATA) \
	  $(PKG_INSTALL_DIR)/usr/lib/$(PKG_NAME)$(PKG_VERSION)/pkgIndex.tcl \
	  $(1)/usr/lib/$(PKG_NAME)$(PKG_VERSION)/
	$(INSTALL_BIN) \
	  $(PKG_INSTALL_DIR)/usr/lib/$(PKG_NAME)$(PKG_VERSION)/lib$(PKG_NAME)$(PKG_VERSION).so \
	  $(1)/usr/lib/$(PKG_NAME)$(PKG_VERSION)/

endef


$(eval $(call BuildPackage,$(PKG_NAME)))
