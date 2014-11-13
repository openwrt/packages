#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=smcroute
PKG_VERSION:=2.0.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0+

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=ftp://troglobit.com/smcroute/
PKG_MD5SUM:=cbf478e52ab9ae411adca41b9d22f68a

include $(INCLUDE_DIR)/package.mk

define Package/smcroute
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Routing and Redirection
	TITLE:=Static Multicast Routing Daemon
	URL:=http://troglobit.com/smcroute.html
	MAINTAINER:=Leonardo Brondani Schenkel <leonardo@schenkel.net>
endef

define Package/smcroute/description
	SMCRoute is a command line tool to manipulate the multicast routes of the Linux kernel.
endef

ifeq ($(HOST_OS),FreeBSD)
	TARGET_CFLAGS += -fno-builtin-log
	TARGET_LDFLAGS += -fno-builtin-log
endif

define Build/Compile
	$(MAKE) CC="$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS)" -C $(PKG_BUILD_DIR) all
endef

define Package/smcroute/conffiles
	/etc/smcroute.conf
endef

define Package/smcroute/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/smcroute $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mcsender $(1)/usr/bin/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/smcroute.conf $(1)/etc
	$(INSTALL_BIN) ./files/smcroute.init $(1)/etc/init.d/smcroute
endef

$(eval $(call BuildPackage,smcroute))
