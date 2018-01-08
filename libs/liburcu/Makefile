#
# Copyright (C) 2015 OpenWrt.org
# Copyright (C) 2014-2018 CZ.NIC, z.s.p.o. <knot-dns@labs.nic.cz>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=liburcu
PKG_VERSION:=0.9.4
PKG_RELEASE:=1

PKG_MAINTAINER:=Daniel Salzman <daniel.salzman@nic.cz>
PKG_LICENSE:=LGPL-2.1 GPL-2.0 GPL-3.0 MIT

PKG_SOURCE:=userspace-rcu-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://lttng.org/files/urcu/
PKG_HASH:=ec6c909249040dfa59bb34686482b62072ce5477f5e2e2153dac47de50b36b68

PKG_BUILD_DIR:=$(BUILD_DIR)/userspace-rcu-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/liburcu
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=User-space Read-Copy-Update library
	URL:=https://lttng.org/
	DEPENDS:=+libpthread
endef

define Package/liburcu/description
	Userspace Read-Copy-Update library.
endef

define Build/InstallDev
	$(INSTALL_DIR)						$(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/urcu*		$(1)/usr/include/
	$(INSTALL_DIR)						$(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liburcu*.{a,so*}	$(1)/usr/lib/
endef

define Package/liburcu/install
	$(INSTALL_DIR)					$(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liburcu*.so.*	$(1)/usr/lib/
endef

$(eval $(call BuildPackage,liburcu))
