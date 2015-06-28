#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gnupg
PKG_VERSION:=1.4.19
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=ftp://ftp.franken.de/pub/crypt/mirror/ftp.gnupg.org/gcrypt/gnupg \
	ftp://ftp.gnupg.org/gcrypt/gnupg
PKG_MD5SUM:=3af4ab5b3113b3e28d3551ecf9600785

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/gnupg
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+zlib +libncurses +libreadline
  TITLE:=GNU privacy guard - a free PGP replacement
  URL:=http://www.gnupg.org/
endef

define Package/gnupg/description
 GnuPG is GNU's tool for secure communication and data storage.
 It can be used to encrypt data and to create digital signatures.
 It includes an advanced key management facility and is compliant
 with the proposed OpenPGP Internet standard as described in RFC2440.
 .
 GnuPG does not use any patented algorithms so it cannot be compatible
 with PGP2 because it uses IDEA (which is patented worldwide).
endef

CONFIGURE_ARGS += \
	--disable-rpath \
	--disable-asm \
	--disable-gnupg-iconv \
	--disable-card-support \
	--disable-agent-support \
	--disable-bzip2 \
	--disable-exec \
	--disable-ldap \
	--disable-hkp \
	--disable-finger \
	--disable-ftp \
	--disable-dns-srv \
	--enable-fake-curl \
	--disable-regex \

MAKE_FLAGS += \
	SUBDIRS="m4 intl zlib util mpi cipher tools g10 keyserver ${checks}" \

define Package/gnupg/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gpg $(1)/usr/bin/
endef

$(eval $(call BuildPackage,gnupg))
