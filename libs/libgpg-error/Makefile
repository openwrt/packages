#
# Copyright (C) 2005-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libgpg-error
PKG_VERSION:=1.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=ftp://ftp.gnupg.org/gcrypt/libgpg-error
PKG_MD5SUM:=8f0eb41a344d19ac2aa9bd101dfb9ce6

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libgpg-error
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GnuPG error handling helper library
  URL:=http://www.gnupg.org/related_software/libgpg-error/
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
endef

define Package/libgpg-error/description
	An helper library for common error codes and descriptions.
	This is a library that defines common error values for all GnuPG
	components. Among these are GPG, GPGSM, GPGME, GPG-Agent, libgcrypt,
	Libksba, DirMngr, Pinentry, SmartCard Daemon and possibly more in the
	future.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--disable-rpath

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin $(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/gpg-error-config \
		$(2)/bin/
	$(SED) \
		's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' \
		$(2)/bin/gpg-error-config
	ln -sf $(STAGING_DIR)/host/bin/gpg-error-config $(1)/usr/bin/gpg-error-config

	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/gpg-error.h \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libgpg-error.{la,a,so*} \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/share/aclocal
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/share/aclocal/gpg-error.m4 \
		$(1)/usr/share/aclocal/
endef

define Package/libgpg-error/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libgpg-error.so.* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libgpg-error))
