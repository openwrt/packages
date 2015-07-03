#
# Copyright (C) 2008-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ngircd
PKG_VERSION:=18
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:= \
        http://ngircd.barton.de/pub/ngircd/ \
        ftp://ftp.berlios.de/pub/ngircd/
PKG_MD5SUM:=4958c8b2d128cf3e9888af3f782892a1

PKG_INSTALL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/ngircd/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Instant Messaging
  DEPENDS:=+zlib
  TITLE:=Next Generation IRC Server
  URL:=http://ngircd.barton.de
endef

define Package/ngircd/Default/description
  ngIRCd is an Open Source server for the Internet Relay Chat (IRC), which
  is developed and published under the terms of the GNU General Public Licence.
  ngIRCd means "next generation IRC daemon", it's written from scratch and
  not deduced from the "grandfather of IRC daemons", the daemon of the IRCNet.
endef

define Package/ngircd
  $(call Package/ngircd/Default)
  TITLE+= (with OpenSSL support)
  DEPENDS+= +libopenssl
  VARIANT:=ssl
endef

define Package/ngircd/conffiles
/etc/ngircd.conf
endef

define Package/ngircd/description
  $(call Package/ngircd/Default/description)
  This package is built with OpenSSL support.
endef

define Package/ngircd-nossl
$(call Package/ngircd/Default)
  TITLE+= (without OpenSSL support)
  VARIANT:=nossl
endef

Package/ngircd-nossl/conffiles = $(Package/ngircd/conffiles)

define Package/ngircd-nossl/description
  $(call Package/ngircd/Default/description)
  This package is built without OpenSSL support.
endef

ifeq ($(BUILD_VARIANT),ssl)
	CONFIGURE_ARGS += \
		--with-openssl="$(STAGING_DIR)/usr"
endif

ifeq ($(BUILD_VARIANT),nossl)
	CONFIGURE_ARGS += \
		--without-openssl
endif

define Package/ngircd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ngircd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/ngircd.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ngircd.init $(1)/etc/init.d/ngircd
endef

Package/ngircd-nossl/install = $(Package/ngircd/install)

$(eval $(call BuildPackage,ngircd))
$(eval $(call BuildPackage,ngircd-nossl))
