#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mailsend
PKG_VERSION:=1.17b15
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/muquit/mailsend/archive/$(PKG_VERSION)
PKG_MD5SUM:=60103c411a8627e893d35e7836f904e8

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYRIGHT

include $(INCLUDE_DIR)/package.mk

define Package/mailsend
	SECTION:=mail
	CATEGORY:=Mail
	TITLE:=A command-line mail sender
	DEPENDS:=+MAILSEND_SSL:libopenssl
	URL:=https://github.com/muquit/mailsend
endef

define Package/mailsend/config
config MAILSEND_SSL
        bool "SSL support"
        depends on PACKAGE_mailsend
        default n
        help
          Implements SSL support in mailsend (using libopenssl).
endef

ifeq ($(CONFIG_MAILSEND_SSL),y)
  CONFIGURE_ARGS+= --with-openssl=$(STAGING_DIR)/usr
endif

define Package/mailsend/description
  Mailsend is a simple command line program to send mail via SMTP protocol.
  SSL is supported via OpenSSL (optional).
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)
endef

define Package/mailsend/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mailsend $(1)/usr/bin/
endef

$(eval $(call BuildPackage,mailsend))
