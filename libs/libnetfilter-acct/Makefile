#
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libnetfilter_acct
PKG_VERSION:=1.0.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:= \
	http://www.netfilter.org/projects/libnetfilter_acct/files/ \
	ftp://ftp.netfilter.org/pub/libnetfilter_acct/ \
	http://mirrors.evolva.ro/netfilter.org/libnetfilter_acct/
PKG_MD5SUM:=2118d9514c079839ebd9cb3144ad2ad7

PKG_LICENSE:=LGPL-2.1+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libnetfilter-acct
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=API to extended accounting infrastructure
  URL:=http://www.netfilter.org/projects/libnetfilter_acct/
  DEPENDS:=+libmnl
endef

define Package/libnetfilter-acct/description
 libnetfilter_acct is a userspace library providing a programming interface
 (API) to the extended accounting infrastructure.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-static \
	--enable-shared \


define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/libnetfilter_acct \
		$(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libnetfilter_acct*.{so*,a,la} \
		$(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libnetfilter_acct.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libnetfilter-acct/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnetfilter_acct.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libnetfilter-acct))
