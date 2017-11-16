#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=emailrelay
PKG_VERSION:=1.9
PKG_RELEASE:=5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-src.tar.gz
PKG_SOURCE_URL:=@SF/emailrelay/$(PKG_VERSION)
PKG_HASH:=869a3e2d053237d7f63784acc25e748af2dbf2d9b9c5c48e4a5269d4e4b5bda0
PKG_MAINTAINER:=Federico Di Marco <fededim@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_CONFIG_DEPENDS:=CONFIG_EMAILRELAY_SUPPORT_VERBOSE_DBG CONFIG_EMAILRELAY_SSL

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

#include $(INCLUDE_DIR)/uclibc++.mk   # $(CXX_DEPENDS)
include $(INCLUDE_DIR)/package.mk

define Package/emailrelay
  SECTION:=mail
  CATEGORY:=Mail
  DEPENDS:=+EMAILRELAY_SSL:libopenssl +libstdcpp
  TITLE:=A simple SMTP proxy and MTA
  URL:=http://emailrelay.sourceforge.net/
  MENU:=1
endef


define Package/emailrelay/config
config EMAILRELAY_SUPPORT_VERBOSE_DBG
	bool "Enable support for extended logging"
	depends on PACKAGE_emailrelay
	default n
	help
	  Enables support for extended logging (must also be explicitely enabled by using command line switch --debug when starting emailrelay)

config EMAILRELAY_SSL
	bool "Enable support for OpenSSL"
	depends on PACKAGE_emailrelay
	default y
	select PACKAGE_libopenssl
	help
 	  Builds the package with OpenSSL support (SSMTP is supported).
endef



define Package/emailrelay/description
 Emailrelay is a simple SMTP proxy and store-and-forward message transfer agent (MTA).

 When running as a proxy all e-mail messages can be passed through
 a user-defined program, such as a spam filter, which can drop,
 re-address or edit messages as they pass through. When running
 as a store-and-forward MTA incoming messages are stored in a
 local spool directory, and then forwarded to the next SMTP
 server on request.
endef


define Package/emailrelay/conffiles
/etc/config/emailrelay
/etc/emailrelay.auth
endef


CONFIGURE_ARGS += \
	--with-pam=no \
	--enable-testing=no

CONFIGURE_VARS += \
	CXXFLAGS="$$$$CXXFLAGS -fno-rtti"


ifeq ($(CONFIG_EMAILRELAY_SSL),y)
	CONFIGURE_ARGS += \
		--with-openssl
else
	CONFIGURE_ARGS += \
		--with-openssl=no
endif


ifeq ($(CONFIG_EMAILRELAY_SUPPORT_VERBOSE_DBG),y)
	CONFIGURE_ARGS += \
		--enable-debug=yes
endif

ifeq ($(CONFIG_OPENSSL_WITH_SSL3),y)
	CONFIGURE_VARS += \
		CXXFLAGS="$$$$CXXFLAGS -DSSL3_SUPPORT"
endif

define Package/emailrelay/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/main/emailrelay $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/main/emailrelay-filter-copy $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/main/emailrelay-passwd $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/main/emailrelay-poke $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/main/emailrelay-submit $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) files/$(PKG_NAME).auth $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/$(PKG_NAME).config $(1)/etc/config/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
endef


$(eval $(call BuildPackage,emailrelay))
