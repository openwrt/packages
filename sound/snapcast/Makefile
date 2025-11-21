# SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=snapcast
PKG_VERSION:=0.28.0
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/badaix/snapcast.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH=288325fc8b134502adb522711c18210794734675684cf5d8eba8a0a82778f6c9

PKG_MAINTAINER:=Szabolcs Hubai <szab.hu@gmail.com>, David Andreoletti <david@andreoletti.net>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:badaix:snapcast

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += -DBUILD_TESTS=OFF
CMAKE_OPTIONS += -DBUILD_WITH_PULSE=OFF
CMAKE_OPTIONS += -DBUILD_WITH_AVAHI=OFF

define Package/snapcast/Default
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=Synchronous multiroom audio player
  DEPENDS:=+AUDIO_SUPPORT:alsa-lib +libexpat +libatomic +libogg +libflac +libopus +boost +libsoxr
  URL:=https://github.com/badaix/snapcast
endef

define Package/snapcast/Default/description
  Synchronous audio player - Snapcast

  Snapcast is a multi-room client-server audio player,
  where all clients are time synchronized with the server
  to play perfectly synced audio.
  It's not a standalone player, but an extension that turns
  your existing audio player into a Sonos-like multiroom solution.
  Audio is captured by the server and routed to the connected clients.
  Several players can feed audio to the server in parallel
  and clients can be grouped to play the same audio stream.
  One of the most generic ways to use Snapcast is in conjunction
  with the Music Player Daemon (MPD) or Mopidy.

endef

define Package/snapserver
  $(call Package/snapcast/Default)
  TITLE+= (server)
  DEPENDS+=+libvorbis
endef

define Package/snapclient
  $(call Package/snapcast/Default)
  TITLE+= (client)
  DEPENDS+=+libvorbisidec
endef

define Package/snapserver/description
  $(call Package/snapcast/Default/description)
  This package contains the Snapcast server.
endef

define Package/snapclient/description
  $(call Package/snapcast/Default/description)
  This package contains the Snapcast client.
endef

define Package/snapserver/conffiles
/etc/config/snapserver
/etc/snapserver.conf
endef

define Package/snapclient/conffiles
/etc/config/snapclient
endef

define Package/snapserver/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/snapserver $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/snapserver.init $(1)/etc/init.d/snapserver
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/server/etc/snapserver.conf $(1)/etc/snapserver.conf
	$(SED) 's/.*doc_root *=/#doc_root =/' $(1)/etc/snapserver.conf
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/snapserver.conf $(1)/etc/config/snapserver
endef

define Package/snapclient/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/snapclient $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/snapclient.init $(1)/etc/init.d/snapclient
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/snapclient.conf $(1)/etc/config/snapclient
endef

$(eval $(call BuildPackage,snapserver))
$(eval $(call BuildPackage,snapclient))
