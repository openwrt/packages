#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ssmtp
PKG_VERSION:=2.64
PKG_RELEASE:=7
PKG_MAINTAINER:=Dirk Brenken <dev@brenken.org>
PKG_LICENSE:=GPL-2.0-or-later
PKG_CPE_ID:=cpe:/a:ssmtp:ssmtp

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).orig.tar.bz2
PKG_SOURCE_URL:=http://ftp.debian.org/debian/pool/main/s/ssmtp
PKG_HASH:=22c37dc90c871e8e052b2cab0ad219d010fa938608cd66b21c8f3c759046fa36

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += $(TARGET_CPPFLAGS)

define Package/ssmtp
	SECTION:=mail
	CATEGORY:=Mail
	DEPENDS:=+libopenssl
	TITLE:=A minimal and secure mail sender with ssl support
	URL:=http://packages.debian.org/ssmtp
endef

define Package/ssmtp/description
A secure, effective and simple way of getting mail off a system to your mail hub.
Mail is simply forwarded to the configured mailhost, no daemons running in the background.
Extremely easy configuration.

endef

define Package/ssmtp/conffiles
/etc/ssmtp/ssmtp.conf
/etc/ssmtp/revaliases
endef

CONFIGURE_VARS += \
	LIBS="$(TARGET_LDFLAGS) -lcrypto -lssl"

CONFIGURE_ARGS += \
	--enable-ssl

define Package/ssmtp/install
	$(INSTALL_DIR) $(1)/etc/ssmtp
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/ssmtp.conf $(1)/etc/ssmtp/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/revaliases $(1)/etc/ssmtp/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ssmtp $(1)/usr/sbin/
	ln -s /usr/sbin/ssmtp $(1)/usr/sbin/sendmail
endef

$(eval $(call BuildPackage,ssmtp))
