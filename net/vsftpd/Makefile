#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vsftpd
PKG_VERSION:=3.0.3
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://security.appspot.com/downloads/
PKG_HASH:=9d4d2bf6e6e2884852ba4e69e157a2cecd68c5a7635d66a3a8cf8d898c955ef7

PKG_MAINTAINER:=Cezary Jackiewicz <cezary@eko.one.pl>
PKG_LICENSE:=GPLv2
PKG_CPE_ID:=cpe:/a:beasts:vsftpd

include $(INCLUDE_DIR)/package.mk

define Package/vsftpd/Default
  SUBMENU:=File Transfer
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Fast and secure FTP server
  URL:=https://security.appspot.com/vsftpd.html
endef


define Package/vsftpd
$(call Package/vsftpd/Default)
  VARIANT:=notls
  TITLE+= (no TLS)
endef

define Package/vsftpd-tls
$(call Package/vsftpd/Default)
  VARIANT:=tls
  TITLE+= (TLS)
  DEPENDS+=+libopenssl
endef

define Package/vsftpd/conffiles
/etc/vsftpd.conf
/etc/vsftpd
endef

Package/vsftpd-tls/conffiles=$(Package/vsftpd/conffiles)

ifneq ($(CONFIG_USE_MUSL),)
  NLSSTRING:=-lcrypt
else
  NLSSTRING:=-lcrypt -lnsl
endif

TARGET_CFLAGS += -D_GNU_SOURCE -include fcntl.h

ifeq ($(BUILD_VARIANT),notls)
 define Build/Compile
	$(SED) 's/-lcrypt -lnsl/$(NLSSTRING)/' $(PKG_BUILD_DIR)/Makefile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		vsftpd
 endef
endif

ifeq ($(BUILD_VARIANT),tls)
 define Build/Compile
	$(SED) 's/#undef VSF_BUILD_SSL/#define VSF_BUILD_SSL/' $(PKG_BUILD_DIR)/builddefs.h
	$(SED) 's/-lcrypt -lnsl/-lcrypt -lnsl -lssl -lcrypto/' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's/-lcrypt -lnsl/$(NLSSTRING)/' $(PKG_BUILD_DIR)/Makefile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		vsftpd
 endef
endif

define Package/vsftpd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/$(PKG_NAME).conf $(1)/etc/$(PKG_NAME).conf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/vsftpd
endef

Package/vsftpd-tls/install=$(Package/vsftpd/install)

$(eval $(call BuildPackage,vsftpd))
$(eval $(call BuildPackage,vsftpd-tls))
