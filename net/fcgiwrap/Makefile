
# Copyright (C) 2012-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fcgiwrap
PKG_VERSION:=1.1.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/gnosek/fcgiwrap.git
PKG_SOURCE_DATE:=2017-09-08
PKG_SOURCE_VERSION:=99c942c90063c73734e56bacaa65f947772d9186
PKG_MIRROR_HASH:=1f9b854726914e97cd2d18cb5743378fafd4c40daba77ec33c8d565ec5cfbc6b
PKG_MAINTAINER:=yhfudev
PKG_LICENSE:=MIT

PKG_BUILD_DIR:=$(BUILD_DIR)/fcgiwrap-$(PKG_VERSION)

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

CONFIGURE_ARGS += \
	--with-systemd

include $(INCLUDE_DIR)/package.mk

define Package/fcgiwrap
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=fcgiwrap for web server
  URL:=https://github.com/gnosek/fcgiwrap.git
  DEPENDS:=+spawn-fcgi +fcgi
  MENU:=0
endef

define Package/fcgiwrap/description
  Simple FastCGI wrapper for CGI scripts
endef

TARGET_CFLAGS += 
TARGET_LDFLAGS += 

define Package/fcgiwrap/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/fcgiwrap $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/fcgiwrap.init $(1)/etc/init.d/fcgiwrap
endef

define Build/Prepare
	$(call Build/Prepare/Default)
endef

$(eval $(call BuildPackage,fcgiwrap))

