#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=forked-daapd
PKG_VERSION:=22.3
PKG_RELEASE:=20150222
PKG_REV:=81b0d330691ce22879514af04c7d831bca8a6e19

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/ejurgensen/forked-daapd.git
PKG_SOURCE_VERSION:=$(PKG_REV)

PKG_BUILD_DEPENDS:=gperf/host
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0
PKG_INSTALL:=1

PKG_MAINTAINER:=Espen Jürgensen <espenjurgensen+openwrt@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/forked-daapd
SECTION:=sound
CATEGORY:=Sound
TITLE:=iTunes (DAAP) server for Apple Remote and AirPlay
URL:=https://github.com/ejurgensen/forked-daapd
DEPENDS:=+libgpg-error +libgcrypt +libgdbm +zlib +libexpat +libunistring \
	+libevent2 +libdaemon +libantlr3c +confuse +glib2 +alsa-lib +libffmpeg-full \
	+mxml +libavahi-client +sqlite3-cli +libplist +libcurl
endef

define Package/forked-daapd/conffiles
/etc/forked-daapd.conf
endef

CONFIGURE_ARGS += \
	--enable-itunes \
	--enable-lastfm

TARGET_CFLAGS += $(FPIC)
TARGET_LDFLAGS += -Wl,-rpath-link,$(STAGING_DIR)/usr/lib

define Package/forked-daapd/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/forked-daapd.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/forked-daapd
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/forked-daapd/* $(1)/usr/lib/forked-daapd/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/forked-daapd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/forked-daapd.init $(1)/etc/init.d/forked-daapd
endef

$(eval $(call BuildPackage,forked-daapd))
