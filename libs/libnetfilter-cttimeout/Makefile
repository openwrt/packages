#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libnetfilter_cttimeout
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:= \
	http://www.netfilter.org/projects/libnetfilter_cttimeout/files/ \
	ftp://ftp.netfilter.org/pub/libnetfilter_cttimeout/ \
	http://mirrors.evolva.ro/netfilter.org/libnetfilter_cttimeout/
PKG_MD5SUM:=7697437fc9ebb6f6b83df56a633db7f9

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libnetfilter-cttimeout
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=API to connection tracking timeout infrastructure
  URL:=http://www.netfilter.org/projects/libnetfilter_cttimeout/
  DEPENDS:=+libmnl
endef

define Package/libnetfilter-queue/description
 libnetfilter_cttimeout is the userspace library that provides the programming
 interface to the fine-grain connection tracking timeout infrastructure.
 With this library, you can create, update and delete timeout policies that can
 be attached to traffic flows.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-static \
	--enable-shared \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/libnetfilter_cttimeout \
		$(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libnetfilter_cttimeout*.{so*,a,la} \
		$(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libnetfilter_cttimeout.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libnetfilter-cttimeout/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnetfilter_cttimeout*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libnetfilter-cttimeout))
