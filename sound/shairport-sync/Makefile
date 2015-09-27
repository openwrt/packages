#
# Copyright (C) 2014-2015 OpenWrt.org  
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=shairport-sync
PKG_VERSION:=2.4.1
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/mikebrady/shairport-sync.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:= +libpthread +libopenssl +libavahi-client +alsa-lib +libdaemon +libsoxr +libconfig

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS+= \
	--with-alsa \
	--with-avahi \
	--with-soxr \
	--with-ssl=openssl \
	--with-metadata

define Build/Configure
	(cd $(PKG_BUILD_DIR); autoreconf -i -f)
	$(call Build/Configure/Default, )
endef

define Package/shairport-sync/Default
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=iPhone/iTunes/AirPlay/Quicktime Player compatible Audio Player
endef


define Package/shairport-sync
  $(Package/shairport-sync/Default)
   DEPENDS:= +libpthread +libopenssl +libavahi-client +alsa-lib +libdaemon +libsoxr +libpopt +libconfig
endef

define Package/shairport-sync/description
  Shairport Sync emulates an AirPort Express by playing synchronized audio
  from iTunes and AirPlay sources including iPhones, Quicktime Player and
  third party sources such as forkedDaapd.
  Audio played by a Shairport Sync-powered device stays synchronised with the source
  and hence with similar devices playing the same source.
  Thus, for example, synchronised multi-room audio is possible without difficulty.
  (Hence the name Shairport Sync, BTW.)
  Shairport Sync does not support AirPlay video or photo streaming.
endef


define Package/shairport-sync/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/shairport-sync $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) ./files/init.d/shairport-sync $(1)/etc/init.d/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/scripts/shairport-sync.conf $(1)/etc/shairport-sync.conf.sample
	$(INSTALL_DATA) ./files/asound.conf $(1)/etc/
endef


$(eval $(call BuildPackage,shairport-sync))
