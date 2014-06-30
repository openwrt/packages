#
# Copyright (C) 2009-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libffi
PKG_VERSION:=3.0.13
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=ftp://sourceware.org/pub/libffi/
PKG_MD5SUM:=45f3b6dbc9ee7c7dfbbbc5feba571529

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/libffi
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Foreign Function Interface (FFI) library
  URL:=http://sourceware.org/libffi/
endef

define Package/libffi/description
The libffi library provides a portable, high level programming interface to
various calling conventions. This allows a programmer to call any function
specified by a call interface description at run-time.

FFI stands for Foreign Function Interface. A foreign function interface is the
popular name for the interface that allows code written in one language to call
code written in another language. The libffi library really only provides the
lowest, machine dependent layer of a fully featured foreign function interface.
A layer must exist above libffi that handles type conversions for values passed
between the two languages.
endef

CONFIGURE_PATH = build
CONFIGURE_CMD = ../configure
MAKE_PATH = build

define Build/Configure
	mkdir -p $(PKG_BUILD_DIR)/build
	$(Build/Configure/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libffi.{so*,a,la} \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* \
		$(1)/usr/lib/pkgconfig/

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libffi-$(PKG_VERSION)/include/*.h \
		$(1)/usr/include/
endef

define Package/libffi/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libffi.so.* \
		$(1)/usr/lib/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libffi))
