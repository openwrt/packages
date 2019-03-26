#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=apinger
PKG_VERSION:=0.6.1
PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Jajcus/apinger.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=c7da72f7ec26eedd7fd8d224c0e10787b204f94e
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=c6739bef32568877ad63dbfa8e34b617a287e225a0344d4c41ba891e1f25d487

PKG_MAINTAINER:=Alex Samorukov <samm@os2.kiev.ua>
PKG_LICENSE:= GPL-2.0

PKG_FIXUP:=autoreconf

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/apinger
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Tool which monitors various IP devices by simple ICMP echo requests
  URL:=https://github.com/Jajcus/apinger
  PKG_MAINTAINER:=Alex Samorukov <samm@os2.kiev.ua>
endef

define Package/apinger/description
	Alarm Pinger (apinger) is a little tool which monitors various IP devices by
	simple ICMP echo requests. There are various other tools, that can do this,
	but most of them are shell or perl scripts, spawning many processes, thus much
	CPU-expensive, especially when one wants continuous monitoring and fast
	response on target failure.  Alarm Pinger is a single program written in C, so
	it doesn't need much CPU power even when monitoring many targets with frequent
	probes.  Alarm Pinger supports both IPv4 and IPv6. The code have been tested
	on Linux and FreeBSD.
endef

define Package/apinger/conffiles
/etc/apinger.conf
endef

define Build/Configure
	$(call Build/Configure/Default)
endef

define Package/apinger/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/apinger $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/apinger.conf $(1)/etc/apinger.conf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/apinger.init $(1)/etc/init.d/apinger
endef

$(eval $(call BuildPackage,apinger))

