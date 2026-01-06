#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=emailrelay
PKG_VERSION:=2.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-src.tar.gz
PKG_SOURCE_URL:=@SF/emailrelay/$(PKG_VERSION)
PKG_HASH:=30c106ca66d75f7e6de2baf22e516024776c699ac27abdd570fbb9319053b4b9

PKG_MAINTAINER:=Federico Di Marco <fededim@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_CONFIG_DEPENDS:= \
	CONFIG_EMAILRELAY_SUPPORT_VERBOSE_DBG \
	CONFIG_EMAILRELAY_SSL \
	CONFIG_EMAILRELAY_SSL_MBEDTLS\
	CONFIG_EMAILRELAY_NOSSL

PKG_BUILD_FLAGS:=gc-sections lto

include $(INCLUDE_DIR)/package.mk

define Package/emailrelay
  SECTION:=mail
  CATEGORY:=Mail
  DEPENDS:=+EMAILRELAY_SSL:libopenssl +EMAILRELAY_SSL_MBEDTLS:libmbedtls +libstdcpp
  TITLE:=E-MailRelay A lightweight email server
  URL:=https://emailrelay.sourceforge.net/
  MENU:=1
endef


define Package/emailrelay/config
	source "$(SOURCE)/Config.in"
endef



define Package/emailrelay/description
 E-MailRelay is a simple SMTP proxy and store-and-forward MTA with POP access to spooled messages.

 It can be used as a personal internet mail server with spam filtering and DNSBL connection blocking.
 Forwarding can be to a fixed smarthost or using DNS MX routing.

 External scripts can be used for address validation and e-mail message processing.
endef


define Package/emailrelay/conffiles
/etc/config/emailrelay
/etc/emailrelay.auth
endef


CONFIGURE_ARGS += \
	--without-doxygen \
	--without-man2html \
	--without-pam \
	--disable-bsd \
	--disable-gui \
	--disable-mac \
	--disable-testing \
	--disable-windows

ifeq ($(CONFIG_EMAILRELAY_SSL),y)
	CONFIGURE_ARGS += \
		--with-openssl
else
	CONFIGURE_ARGS += \
		--without-openssl
endif

ifeq ($(CONFIG_EMAILRELAY_SSL_MBEDTLS),y)
	CONFIGURE_ARGS += \
		--with-mbedtls
else
	CONFIGURE_ARGS += \
		--without-mbedtls
endif

ifeq ($(CONFIG_EMAILRELAY_SUPPORT_VERBOSE_DBG),y)
	CONFIGURE_ARGS += \
		--enable-debug=yes
endif

TARGET_CXXFLAGS += -Wl,--as-needed

define Package/emailrelay/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/main/emailrelay $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/main/emailrelay-passwd $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/main/emailrelay-submit $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) files/$(PKG_NAME).auth $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/$(PKG_NAME).config $(1)/etc/config/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
endef


$(eval $(call BuildPackage,emailrelay))
