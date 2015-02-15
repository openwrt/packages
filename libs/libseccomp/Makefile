#
# Copyright (C) 2005-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libseccomp
PKG_VERSION:=2.2.0
PKG_RELEASE:=1
PKG_USE_MIPS16:=0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/seccomp/libseccomp/releases/download/v$(PKG_VERSION)/
PKG_MD5SUM:=e9509301a1fc024cd10127ac1f31792a
PKG_MAINTAINER:=Nikos Mavrogiannopoulos <nmav@gnutls.org>

PKG_INSTALL:=1
PKG_LIBTOOL_PATHS:=. lib
PKG_CHECK_FORMAT_SECURITY:=0

include $(INCLUDE_DIR)/package.mk


define Package/libseccomp/Default
  SUBMENU:=
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=seccomp
  URL:=https://github.com/seccomp/libseccomp/wiki
endef

define Package/libseccomp/Default/description
 The libseccomp library provides an easy to use, platform independent, interface
 to the Linux Kernel's syscall filtering mechanism.  The libseccomp API is
 designed to abstract away the underlying BPF based syscall filter language and
 present a more conventional function-call based filtering interface that should
 be familiar to, and easily adopted by, application developers.
endef

define Package/libseccomp
$(call Package/libseccomp/Default)
  TITLE+= (library)
  DEPENDS+=
endef

define Package/libseccomp/description
 This package contains the seccomp library.
endef

define Build/Configure
	$(SED) 's,-I$$$${includedir},,g' $(PKG_BUILD_DIR)/configure
	$(SED) 's,-L$$$${libdir},,g' $(PKG_BUILD_DIR)/configure
	$(call Build/Configure/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/seccomp.h \
		$(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libseccomp.{a,so*} \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libseccomp.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libseccomp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libseccomp.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libseccomp))
