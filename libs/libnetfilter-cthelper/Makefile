#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libnetfilter_cthelper
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:= \
	http://www.netfilter.org/projects/libnetfilter_cthelper/files/ \
	ftp://ftp.netfilter.org/pub/libnetfilter_cthelper/ \
	http://mirrors.evolva.ro/netfilter.org/libnetfilter_cthelper/
PKG_MD5SUM:=b2efab1a3a198a5add448960ba011acd

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libnetfilter-cthelper
  CATEGORY:=Libraries
  SECTION:=libs
  TITLE:=API to connection tracking helper infrastructure
  URL:=http://www.netfilter.org/projects/libnetfilter_cthelper/
  DEPENDS:=+libmnl
endef

define Package/libnetfilter-cthelper/description
 libnetfilter_cthelper is the userspace library that provides the programming
 interface to the user-space helper infrastructure available since Linux kernel
 3.6.
 With this library, you register, configure, enable and disable user-space
 helpers.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-static \
	--enable-shared \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/libnetfilter_cthelper \
		$(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libnetfilter_cthelper*.{a,la,so*} \
		$(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libnetfilter_cthelper.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libnetfilter-cthelper/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnetfilter_cthelper*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libnetfilter-cthelper))
