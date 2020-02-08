#
# Copyright (C) 2009-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libffi
PKG_VERSION:=3.2.1
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=ftp://sourceware.org/pub/libffi/
PKG_HASH:=d06ebb8e1d9a22d19e38d63fdb83954253f39bedc5d46232a05645685722ca37

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
  MAINTAINER:=Peter Wagner <tripolar@gmx.at>
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

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libffi.{so*,a,la} \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* \
		$(1)/usr/lib/pkgconfig/
	sed -i -e 's,includedir=.*,includedir=$$$${prefix}/include,' $(1)/usr/lib/pkgconfig/libffi.pc

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/$(PKG_NAME)-$(PKG_VERSION)/include/*.h \
		$(1)/usr/include/
endef

define Package/libffi/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libffi.so.* \
		$(1)/usr/lib/
endef

define Host/Install
	$(call Host/Install/Default)
	# Adjust host libffi headers ; the default rule does
	# not seem to install them to the proper include folder
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/include
	$(CP) \
		$(STAGING_DIR_HOSTPKG)/lib/libffi-$(PKG_VERSION)/include/*.h \
		$(STAGING_DIR_HOSTPKG)/include
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libffi))
