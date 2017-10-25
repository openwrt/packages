#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pigeonhole
PKG_VERSION:=0.4.20
PKG_RELEASE:=1

DOVECOT_VERSION:=2.2

PKG_SOURCE:=dovecot-$(DOVECOT_VERSION)-$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pigeonhole.dovecot.org/releases/$(DOVECOT_VERSION)
PKG_HASH:=6fe17d0b8f25f2ad580e01ad81ce47a9e965255e383a1f80e455f9ca0f00be5b
PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING COPYING.LGPL

PKG_BUILD_DIR:=$(BUILD_DIR)/dovecot-$(DOVECOT_VERSION)-$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/pigeonhole
  SECTION:=mail
  CATEGORY:=Mail
  DEPENDS:=+dovecot
  TITLE:=Mail filtering facilities for Dovecot
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
  URL:=https://wiki2.dovecot.org/Pigeonhole
endef

define Package/pigeonhole/description
  Pigeonhole provides mail filtering facilities for Dovecot using the Sieve
  (RFC 5228) language.
endef

CONFIGURE_ARGS += \
  --with-dovecot=$(STAGING_DIR)/usr/lib/dovecot/ \
  --without-managesieve

CONFIGURE_VARS += \
  LDFLAGS="$(TARGET_LDFLAGS) -L$(STAGING_DIR)/usr/lib/dovecot/" \
  CPPFLAGS="$(TARGET_CPPFLAGS) -I$(STAGING_DIR)/usr/include/dovecot/"

define Package/pigeonhole/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/dovecot/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/dovecot/* $(1)/usr/lib/dovecot/
	find $(1)/usr/lib/dovecot/ -name "*.a" -o -name "*.la" | xargs rm
endef

$(eval $(call BuildPackage,pigeonhole))
