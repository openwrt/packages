#
# Copyright (C) 2005-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libgpg-error
PKG_VERSION:=1.43
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://mirrors.dotsrc.org/gcrypt/libgpg-error \
		http://ring.ksc.gr.jp/archives/net/gnupg/libgpg-error \
		https://www.gnupg.org/ftp/gcrypt/libgpg-error
PKG_HASH:=a9ab83ca7acc442a5bd846a75b920285ff79bdb4e3d34aa382be88ed2c3aebaf

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libgpg-error
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GnuPG error handling helper library
  URL:=https://www.gnupg.org/related_software/libgpg-error/
endef

define Package/libgpg-error/description
	An helper library for common error codes and descriptions.
	This is a library that defines common error values for all GnuPG
	components. Among these are GPG, GPGSM, GPGME, GPG-Agent, libgcrypt,
	Libksba, DirMngr, Pinentry, SmartCard Daemon and possibly more in the
	future.
endef

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--disable-doc \
	--disable-languages \
	--disable-rpath \
	--disable-tests

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin $(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/gpg-error-config \
		$(2)/bin/
	$(SED) \
		's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' \
		$(2)/bin/gpg-error-config
	ln -sf $(STAGING_DIR)/host/bin/gpg-error-config $(1)/usr/bin/gpg-error-config

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/gpgrt-config \
		$(2)/bin/
	$(SED) \
		's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' \
		$(2)/bin/gpgrt-config
	ln -sf $(STAGING_DIR)/host/bin/gpgrt-config $(1)/usr/bin/gpgrt-config

	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/gpg-error.h \
		$(1)/usr/include/

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/gpgrt.h \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libgpg-error.{la,a,so*} \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/share/aclocal
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/share/aclocal/gpg-error.m4 \
		$(1)/usr/share/aclocal/

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/share/aclocal/gpgrt.m4 \
		$(1)/usr/share/aclocal/
endef

define Package/libgpg-error/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libgpg-error.so.* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libgpg-error))
