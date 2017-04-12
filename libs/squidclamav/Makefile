#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=squidclamav

PKG_VERSION=v6.16
PKG_RELEASE:=1
PKG_MAINTAINER:=Marko Ratkaj <marko.ratkaj@sartura.hr>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/darold/squidclamav.git
PKG_SOURCE_VERSION:=7808683bf1367688c0cfbd2b083cc086b755bb3f
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/squidclamav
   SECTION:=libs
   CATEGORY:=Libraries
   TITLE:=squidclamav
   DEPENDS:=+c-icap
   URL:=http://squidclamav.darold.net/
endef

define Package/squidclamav/description
 SquidClamav is an antivirus for Squid proxy based on the Awards winnings ClamAv anti-virus toolkit.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/c_icap/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/c_icap/squidclamav.so $(1)/usr/lib/c_icap/

	$(INSTALL_DIR) $(1)/usr/lib/c_icap
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/c_icap/squidclamav.la $(1)/usr/lib/c_icap/
endef

define Package/squidclamav/install
	$(INSTALL_DIR) $(1)/etc/
	$(INSTALL_CONF) ./files/squidclamav.conf $(1)/etc/

	$(INSTALL_DIR) $(1)/usr/lib/c_icap/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/c_icap/squidclamav.so $(1)/usr/lib/c_icap/

	$(INSTALL_DIR) $(1)/usr/lib/squidclamav/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/squidclamav/* $(1)/usr/lib/squidclamav/

	$(INSTALL_DIR) $(1)/usr/share/c_icap/templates/squidclamav/en
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/share/c_icap/templates/squidclamav/en/MALWARE_FOUND \
		$(1)/usr/share/c_icap/templates/squidclamav/en/
endef

$(eval $(call BuildPackage,squidclamav))
