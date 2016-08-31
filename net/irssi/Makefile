#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=irssi
PKG_VERSION:=0.8.17
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://irssi.org/files/
PKG_MD5SUM:=ecf64be47978d89a742b435a81cb47db

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/irssi/Default
  SUBMENU:=Instant Messaging
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+glib2 +libncurses +libpthread
  TITLE:=Console IRC client
  MAINTAINER:=Peter Wagner <tripolar@gmx.at>
  URL:=http://irssi.org/
endef

define Package/irssi/Default/description
	Irssi is a terminal based IRC client for UNIX systems.
endef

define Package/irssi
$(call Package/irssi/Default)
  TITLE+= (with OpenSSL support)
  DEPENDS+= +libopenssl
  VARIANT:=ssl
endef

define Package/irssi/description
$(call Package/irssi/Default/description)
 This package is built with OpenSSL support.
endef

define Package/irssi-nossl
$(call Package/irssi/Default)
  TITLE+= (without OpenSSL support)
  VARIANT:=nossl
endef

define Package/irssi-nossl/description
$(call Package/irssi/Default/description)
 This package is built without OpenSSL support.
endef

CONFIGURE_ARGS += \
	--with-perl=no \
	--with-glib-prefix="$(STAGING_DIR)/usr" \
	--with-textui \
	--without-terminfo \
	--without-bot \
	--disable-proxy

EXTRA_CFLAGS+=$(TARGET_CPPFLAGS)
EXTRA_LDFLAGS+=-lncurses

ifeq ($(BUILD_VARIANT),ssl)
	CONFIGURE_ARGS += \
		--with-ssl="$(STAGING_DIR)/usr"
endif

ifeq ($(BUILD_VARIANT),nossl)
	CONFIGURE_ARGS += \
		--without-ssl \
		--disable-ssl
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/irssi
	$(CP) $(PKG_INSTALL_DIR)/usr/include/irssi/* $(1)/usr/include/irssi/
endef

define Package/irssi/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/$(PKG_NAME)
endef

Package/irssi-nossl/install = $(Package/irssi/install)

$(eval $(call BuildPackage,irssi))
$(eval $(call BuildPackage,irssi-nossl))
