#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=udpxy
PKG_SOURCE_VERSION:=53e4672a7522311c40e9f6110ff256041c52c8b4
PKG_VERSION:=2016-09-18-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pcherenkov/udpxy.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=bb6ca16706b011cc473d296ebc6d6e57fe5cfc2a0fc46e81399fba01d6484b3e
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=gpl.txt

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

MAKE_PATH:=chipmunk

define Package/udpxy
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Convert UDP IPTV streams into HTTP streams
  URL:=https://github.com/pcherenkov/udpxy
endef

define Package/udpxy/description
	udproxy makes it possible to convert UDP IPTV streams into HTTP
	streams which can be viewed even over WLANs. HTTP streams do
	not generate huge amounts of multicast traffic, so a sd stream
	only takes about 300k. Interesting for peoply who have IPTV at
	home and do not want to rent multiple decoders from their
	provider but just use their own streaming client (for example
	popcornhour/mediatomb/vlc).
endef

define Package/udpxy/conffiles
/etc/config/udpxy
endef

MAKE_FLAGS += \
	INSTALLROOT="$(PKG_INSTALL_DIR)/usr" \
	ALL_CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)"

define Package/udpxy/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_CONF) ./files/udpxy.conf $(1)/etc/config/udpxy
	$(INSTALL_BIN) ./files/udpxy.init $(1)/etc/init.d/udpxy
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/udpxy $(1)/usr/bin/
	ln -sf udpxy $(1)/usr/bin/udpxrec
endef

$(eval $(call BuildPackage,udpxy))
