# SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=snapcast
PKG_VERSION:=0.35.0
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/snapcast/snapcast.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH=b21791cda7f0b403b45401ea3c8b742013d81b5f7fff524bf93365db92320140

PKG_MAINTAINER:=Szabolcs Hubai <szab.hu@gmail.com>, David Andreoletti <david@andreoletti.net>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:badaix:snapcast

# Optional features are individually selectable (see Package/snapserver/config).
# Listing the symbols here reconfigures and rebuilds the package whenever any of
# them is toggled.
PKG_CONFIG_DEPENDS:= \
	CONFIG_SNAPCAST_ALSA \
	CONFIG_SNAPCAST_AVAHI \
	CONFIG_SNAPCAST_EXPAT \
	CONFIG_SNAPCAST_FLAC \
	CONFIG_SNAPCAST_OPUS \
	CONFIG_SNAPCAST_SOXR \
	CONFIG_SNAPCAST_SSL \
	CONFIG_SNAPCAST_VORBIS

# snapserver and snapclient are produced by a single source build, so every
# enabled feature library must be staged whenever the source is built,
# regardless of which of the two binary packages is selected. These are pure
# build-time prerequisites; the precise per-binary runtime dependencies (what
# actually lands on the target) are declared in each Package/* DEPENDS below.
PKG_BUILD_DEPENDS:= \
	$(if $(CONFIG_SNAPCAST_ALSA),alsa-lib) \
	$(if $(CONFIG_SNAPCAST_AVAHI),libavahi-client) \
	$(if $(CONFIG_SNAPCAST_EXPAT),libexpat) \
	$(if $(CONFIG_SNAPCAST_FLAC),libflac) \
	$(if $(CONFIG_SNAPCAST_OPUS),libopus) \
	$(if $(CONFIG_SNAPCAST_SOXR),libsoxr) \
	$(if $(CONFIG_SNAPCAST_SSL),libopenssl) \
	$(if $(CONFIG_SNAPCAST_VORBIS),libvorbis libvorbisidec) \
	boost

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# Every upstream build switch is pinned explicitly for reproducible builds; the
# optional ones follow their config symbol. Client-only desktop backends other
# than ALSA are unavailable on OpenWrt and stay off.
CMAKE_OPTIONS += \
	-DBUILD_TESTS=OFF \
	-DBUILD_WITH_ALSA=$(if $(CONFIG_SNAPCAST_ALSA),ON,OFF) \
	-DBUILD_WITH_AVAHI=$(if $(CONFIG_SNAPCAST_AVAHI),ON,OFF) \
	-DBUILD_WITH_EXPAT=$(if $(CONFIG_SNAPCAST_EXPAT),ON,OFF) \
	-DBUILD_WITH_FLAC=$(if $(CONFIG_SNAPCAST_FLAC),ON,OFF) \
	-DBUILD_WITH_JACK=OFF \
	-DBUILD_WITH_OPUS=$(if $(CONFIG_SNAPCAST_OPUS),ON,OFF) \
	-DBUILD_WITH_PIPEWIRE=OFF \
	-DBUILD_WITH_PULSE=OFF \
	-DBUILD_WITH_SDL2=OFF \
	-DBUILD_WITH_SOXR=$(if $(CONFIG_SNAPCAST_SOXR),ON,OFF) \
	-DBUILD_WITH_SSL=$(if $(CONFIG_SNAPCAST_SSL),ON,OFF) \
	-DBUILD_WITH_TREMOR=$(if $(CONFIG_SNAPCAST_VORBIS),ON,OFF) \
	-DBUILD_WITH_VORBIS=$(if $(CONFIG_SNAPCAST_VORBIS),ON,OFF) \
	-DWERROR=OFF

define Package/snapcast/Default
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=Synchronous multiroom audio player
  URL:=https://github.com/snapcast/snapcast
  # Dependencies common to both binaries. Feature libraries that only one of the
  # two links are added in the respective package below, so each package pulls
  # only what its binary actually needs at runtime.
  DEPENDS:= \
	+SNAPCAST_ALSA:alsa-lib \
	+SNAPCAST_AVAHI:libavahi-client \
	+SNAPCAST_FLAC:libflac \
	+SNAPCAST_OPUS:libopus \
	+SNAPCAST_SSL:libopenssl \
	+libatomic \
	+libogg \
	+libstdcpp
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

# The optional-feature menu is shared by both binaries (single source build), so
# it is declared once. The symbols are free-standing (no "depends on
# PACKAGE_*"): the packages reference them in DEPENDS, and a back-dependency
# here would form a Kconfig recursion.
define Package/snapserver/config
	menu "Snapcast feature selection"

		config SNAPCAST_ALSA
			bool "ALSA support (server capture source + client playback)"
			default y
			help
				Adds a dependency on alsa-lib.

		config SNAPCAST_AVAHI
			bool "Avahi / zeroconf support"
			default n
			help
				Adds a dependency on libavahi-client.

		config SNAPCAST_EXPAT
			bool "EXPAT / XML support (server)"
			default y
			help
				Adds a dependency on libexpat.

		config SNAPCAST_FLAC
			bool "FLAC codec support"
			default y
			help
				Adds a dependency on libflac.

		config SNAPCAST_OPUS
			bool "Opus codec support"
			default y
			help
				Adds a dependency on libopus.

		config SNAPCAST_SOXR
			bool "SOXR resampling support (server)"
			default y
			help
				Adds a dependency on libsoxr.

		config SNAPCAST_SSL
			bool "SSL / TLS support"
			default n
			help
				Adds a dependency on libopenssl.

		config SNAPCAST_VORBIS
			bool "Ogg Vorbis support (server encoder + client Tremor decoder)"
			default y
			help
				Adds dependencies on libvorbis (server) and
				libvorbisidec (client).
	endmenu
endef

define Package/snapserver
  $(call Package/snapcast/Default)
  TITLE+= (server)
  DEPENDS+= \
	+SNAPCAST_EXPAT:libexpat \
	+SNAPCAST_SOXR:libsoxr \
	+SNAPCAST_VORBIS:libvorbis
endef

define Package/snapclient
  $(call Package/snapcast/Default)
  TITLE+= (client)
  DEPENDS+= \
	+SNAPCAST_VORBIS:libvorbisidec
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
