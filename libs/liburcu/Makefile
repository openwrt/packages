#
# Copyright (C) 2015 OpenWrt.org
# Copyright (C) 2014-2018 CZ.NIC, z.s.p.o. <knot-dns@labs.nic.cz>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=liburcu
PKG_VERSION:=0.15.2
PKG_RELEASE:=1

PKG_MAINTAINER:=Daniel Salzman <daniel.salzman@nic.cz>
PKG_LICENSE:=LGPL-2.1-or-later GPL-2.0-or-later MIT
PKG_LICENSE_FILES:=lgpl-2.1.txt gpl-2.0.txt lgpl-relicensing.txt

PKG_SOURCE:=userspace-rcu-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://lttng.org/files/urcu/
PKG_HASH:=59f36f2b8bda1b7620a7eced2634f26c549444818a8313025a3bb09c0766a61d
PKG_BUILD_DIR:=$(BUILD_DIR)/userspace-rcu-$(PKG_VERSION)

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

include $(INCLUDE_DIR)/package.mk

define Package/liburcu
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=User-space Read-Copy-Update library
	URL:=https://lttng.org/
	DEPENDS:=+libpthread @!arc
endef

define Package/liburcu/description
	Userspace Read-Copy-Update library.
endef

ifeq ($(CONFIG_arc),)
define Build/InstallDev
	$(INSTALL_DIR)						$(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/urcu*		$(1)/usr/include/
	$(INSTALL_DIR)						$(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liburcu*.{a,so*}	$(1)/usr/lib/
	$(INSTALL_DIR)						$(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc		$(1)/usr/lib/pkgconfig/
endef
endif

define Package/liburcu/install
	$(INSTALL_DIR)					$(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liburcu*.so.*	$(1)/usr/lib/
endef

$(eval $(call BuildPackage,liburcu))
