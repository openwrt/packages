#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dovecot-pigeonhole
PKG_VERSION_PLUGIN:=0.4.21
PKG_VERSION_DOVECOT:=$(shell make --no-print-directory -C ../dovecot/ val.PKG_VERSION V=s)
PKG_VERSION:=$(PKG_VERSION_DOVECOT)-$(PKG_VERSION_PLUGIN)
PKG_RELEASE:=2

DOVECOT_VERSION:=2.2

PKG_SOURCE:=dovecot-$(DOVECOT_VERSION)-pigeonhole-$(PKG_VERSION_PLUGIN).tar.gz
PKG_SOURCE_URL:=https://pigeonhole.dovecot.org/releases/$(DOVECOT_VERSION)
PKG_HASH:=4ae09cb788c5334d167f5a89ee70b0616c3231e5904ad258ce408e4953cfdd6a
PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING COPYING.LGPL

PKG_BUILD_DIR:=$(BUILD_DIR)/dovecot-$(DOVECOT_VERSION)-pigeonhole-$(PKG_VERSION_PLUGIN)
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/dovecot-pigeonhole
  SECTION:=mail
  CATEGORY:=Mail
  DEPENDS:=+dovecot
  EXTRA_DEPENDS:=dovecot (>= $(PKG_VERSION_DOVECOT))
  TITLE:=Mail filtering facilities for Dovecot
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
  URL:=https://wiki2.dovecot.org/Pigeonhole
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
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/dovecot/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/dovecot/* $(1)/usr/lib/dovecot/
	find $(1)/usr/lib/dovecot/ -name "*.a" -o -name "*.la" | xargs rm
endef

$(eval $(call BuildPackage,dovecot-pigeonhole))
