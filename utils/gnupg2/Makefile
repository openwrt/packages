#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gnupg
PKG_VERSION:=2.4.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://gnupg.org/ftp/gcrypt/gnupg
PKG_HASH:=b58c80d79b04d3243ff49c1c3fc6b5f83138eb3784689563bcdd060595318616

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING COPYING.CC0 COPYING.GPL2 COPYING.LGPL21 COPYING.LGPL3 COPYING.other
PKG_CPE_ID:=cpe:/a:gnupg:gnupg

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

CONFIGURE_VARS += ac_cv_path_GPGRT_CONFIG="$(STAGING_DIR)/usr/bin/gpgrt-config"

define Package/gnupg2/Default
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Encryption
  DEPENDS:=+libgpg-error +libnpth +libassuan +libksba +libgcrypt +zlib +libncurses +libreadline $(ICONV_DEPENDS) $(INTL_DEPENDS)
  TITLE:=GNU privacy guard (version 2) - a free PGP replacement
  URL:=https://gnupg.org/
endef

define Package/gnupg2
  $(call Package/gnupg2/Default)
  MENU:=1
  ALTERNATIVES:=300:/usr/bin/gpg:/usr/bin/gpg2
endef

define Package/gpgv2
  $(call Package/gnupg2/Default)
  TITLE:=GnuPG signature verification only (version 2)
  ALTERNATIVES:=300:/usr/bin/gpgv:/usr/bin/gpgv2
endef

define Package/gnupg2-dirmngr
  $(call Package/gnupg2/Default)
  TITLE:=Keyserver, CRL, and OCSP access for GnuPG (version 2)
  DEPENDS+=+libgnutls
endef

define Package/gnupg2-utils
  $(call Package/gnupg2/Default)
  DEPENDS:=gnupg2 +libcurl
  TITLE:=Key management utilities for GnuPG (version 2)
endef

define Package/gnupg2/description
GnuPG is a complete and free implementation of the OpenPGP standard as
defined by RFC4880 (also known as PGP). GnuPG allows you to encrypt and
sign your data and communications; it features a versatile key
management system, along with access modules for all kinds of public
key directories. GnuPG, also known as GPG, is a command line tool with
features for easy integration with other applications. A wealth of
frontend applications and libraries are available. GnuPG also provides
support for S/MIME and Secure Shell (ssh). 
endef

define Package/gpgv2/description
 GPGv is a stripped down version of GnuPG that only checks signatures.
endef

define Package/gnupg2-dirmngr/description
Since version 2.1 of GnuPG, 'dirmngr' takes care of accessing the
OpenPGP keyservers.  As with previous versions it is also used as a
server for managing and downloading certificate revocation lists (CRLs)
for X.509 certificates, downloading X.509 certificates, and providing
access to OCSP providers.  Dirmngr is invoked internally by 'gpg',
'gpgsm', or via the 'gpg-connect-agent' tool.
endef

define Package/gnupg2-utils/description
 Key management utilities for GnuPG (version 2).
 This package is needed to import keys from a keyserver.
endef

CONFIGURE_ARGS += \
	--with-gpg-error-prefix="$(STAGING_DIR)/usr/" \
	--with-libgcrypt-prefix="$(STAGING_DIR)/usr/" \
	--with-libassuan-prefix="$(STAGING_DIR)/usr/" \
	--with-ksba-prefix="$(STAGING_DIR)/usr/" \
	--with-npth-prefix="$(STAGING_DIR)/usr/" \
	--disable-doc \
	--disable-bzip2 \
	--disable-card-support \
	--disable-ccid-driver \
	--disable-ldap \
	--disable-ntbtls \
	--disable-rpath \
	--disable-sqlite \
	--disable-tests \
	--disable-zip

TARGET_CFLAGS += $(if $(filter-out 5 6 7 8 9,$(word 1,$(subst ., ,$(call qstrip,$(CONFIG_GCC_VERSION))))),-DEXTERN_UNLESS_MAIN_MODULE=static)

define Package/gnupg2/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gpg $(1)/usr/bin/gpg2
endef

define Package/gpgv2/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gpgv $(1)/usr/bin/gpgv2
endef

define Package/gnupg2-dirmngr/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dirmngr $(1)/usr/bin/dirmngr
endef

define Package/gnupg2-utils/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gpgtar $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/kbxutil $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gpg-wks-server $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gpg-agent $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gpg-connect-agent $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gpgsplit $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gpgparsemail $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gpgsm $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/addgnupghome $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/applygnupgdefaults $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/gpg-* $(1)/usr/lib
endef

$(eval $(call BuildPackage,gnupg2))
$(eval $(call BuildPackage,gpgv2))
$(eval $(call BuildPackage,gnupg2-dirmngr))
$(eval $(call BuildPackage,gnupg2-utils))
