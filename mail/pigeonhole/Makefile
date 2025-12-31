#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dovecot-pigeonhole
PKG_VERSION:=0.5.21
PKG_RELEASE:=1

DOVECOT_VERSION:=2.3

PKG_SOURCE:=dovecot-$(DOVECOT_VERSION)-pigeonhole-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pigeonhole.dovecot.org/releases/$(DOVECOT_VERSION)
PKG_HASH:=1ca71d2659076712058a72030288f150b2b076b0306453471c5261498d3ded27

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING COPYING.LGPL
PKG_CPE_ID:=cpe:/a:dovecot:pigeonhole

PKG_BUILD_DIR:=$(BUILD_DIR)/dovecot-$(DOVECOT_VERSION)-pigeonhole-$(PKG_VERSION)
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/dovecot-pigeonhole
  SECTION:=mail
  CATEGORY:=Mail
  DEPENDS:=+dovecot
  EXTRA_DEPENDS:=dovecot (>=2.3.0), dovecot (<2.4.0)
  TITLE:=Mail filtering facilities for Dovecot
  URL:=https://pigeonhole.dovecot.org/
endef

define Package/dovecot-pigeonhole/description
  Pigeonhole provides mail filtering facilities for Dovecot using the Sieve
  (RFC 5228) language.
endef

CONFIGURE_ARGS += \
  --with-dovecot=$(STAGING_DIR)/usr/lib/dovecot/

CONFIGURE_VARS += \
  LDFLAGS="$(TARGET_LDFLAGS) -L$(STAGING_DIR)/usr/lib/dovecot/" \
  CPPFLAGS="$(TARGET_CPPFLAGS) -I$(STAGING_DIR)/usr/include/dovecot/"

define Package/dovecot-pigeonhole/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/dovecot/ $(1)/usr/libexec/dovecot/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/dovecot/* $(1)/usr/lib/dovecot/
	$(CP) $(PKG_INSTALL_DIR)/usr/libexec/dovecot/* $(1)/usr/libexec/dovecot/
	find $(1)/usr/lib/dovecot/ -name "*.a" -o -name "*.la" | $(XARGS) rm
endef

$(eval $(call BuildPackage,dovecot-pigeonhole))
