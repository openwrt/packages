#
# Copyright (C) 2015-2016 Ted Hess
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mpd
PKG_VERSION:=0.19.19
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://www.musicpd.org/download/mpd/0.19/
PKG_MD5SUM:=6e4fca9a9c26dad08b61bac9a91802db
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_IPV6 \

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/mpd/Default
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=Music Player Daemon
  URL:=http://www.musicpd.org/
  DEPENDS:= +glib2 +libcurl +libpthread +libmpdclient +libstdcpp $(ICONV_DEPENDS) \
	    +libflac +BUILD_PATENTED:libmad +libvorbisidec +AUDIO_SUPPORT:alsa-lib \
            +boost +boost-container +libexpat
endef

define Package/mpd/Default/description
 Music Player Daemon (MPD) is a flexible, powerful, server-side
 application for playing music. It is typically controlled over a
 network using one of it's many clients including mpc (console),
 gmpc (gnome), phpmp (php), etc...
endef

define Package/mpd-full
$(call Package/mpd/Default)
  TITLE+= (full)
  DEPENDS+= \
	+libaudiofile +BUILD_PATENTED:libfaad2 +libffmpeg +libid3tag \
	+libmms +libogg +libsndfile +libvorbis +libupnp
  PROVIDES:=mpd
  VARIANT:=full
endef

define Package/mpd-full/description
$(call Package/mpd/Default/description)
 .
 This package contains a full-blown Music Player Daemon.
endef

define Package/mpd-full/conffiles
/etc/mpd.conf
endef

define Package/mpd-mini
$(call Package/mpd/Default)
  TITLE+= (mini)
  PROVIDES:=mpd
  VARIANT:=mini
endef

define Package/mpd-mini/description
$(call Package/mpd/Default/description)
 .
 This package contains a minimal Music Player Daemon, with support for
 only Flac, MP3 & OGG media types & only file: & http: protocols.
endef

define Package/mpd-mini/conffiles
/etc/mpd.conf
endef

define Package/mpd-avahi-service
$(call Package/mpd/Default)
  TITLE+= (Avahi service)
  DEPENDS+=+avahi-daemon
endef

define Package/mpd-avahi-service/description
$(call Package/mpd/Default/description)
 .
 This package contains the service definition for announcing the
 Music Player Daemon service via mDNS/DNS-SD.
endef

define Package/mpd-avahi-service/conffiles
/etc/avahi/services/mpd.service
endef

CONFIGURE_ARGS += \
	$(call autoconf_bool,CONFIG_IPV6,ipv6) \
	--disable-debug \
	--disable-documentation \
	--disable-test \
	--disable-werror \
	\
	--disable-ao \
	--disable-bzip2 \
	--disable-fluidsynth \
	--disable-wildmidi \
	--disable-gme \
	--enable-inotify \
	--disable-icu \
	--disable-eventfd \
	--disable-iso9660 \
	--disable-jack \
	--disable-roar \
	--disable-libwrap \
	--disable-lsr \
	--disable-mikmod \
	--disable-modplug \
	--disable-mpc \
	--disable-mpg123 \
	--disable-openal \
	--disable-opus \
	--disable-pulse \
	--disable-sidplay \
	--disable-solaris-output \
	--disable-sqlite \
	--disable-lame-encoder \
	--disable-twolame-encoder \
	--disable-shine-encoder \
	--enable-wave-encoder \
	--disable-wavpack \
	--disable-wildmidi \
	--disable-zzip \
	--with-zeroconf=no \
	--disable-soxr \
	\
	--enable-curl \
	--enable-flac \
	--enable-httpd-output \
	$(call autoconf_bool,CONFIG_BUILD_PATENTED,mad) \
	$(call autoconf_bool,CONFIG_AUDIO_SUPPORT,alsa) \
	--enable-tcp \
	--enable-un \

CONFIGURE_VARS += \
	FLAC_CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include/FLAC" \
	FLAC_LIBS="$(TARGET_LDFLAGS) -lFLAC" \
	$(if $(CONFIG_BUILD_PATENTED),MAD_CFLAGS="$(TARGET_CFLAGS)") \
	$(if $(CONFIG_BUILD_PATENTED),MAD_LIBS="$(TARGET_LDFLAGS) -lmad") \

TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib $(if $(ICONV_FULL),-liconv)

ifeq ($(BUILD_VARIANT),full)

  CONFIGURE_ARGS += \
	--enable-upnp \
	$(call autoconf_bool,CONFIG_BUILD_PATENTED,aac) \
	--enable-audiofile \
	--enable-fifo \
	--enable-ffmpeg \
	--enable-id3 \
	--enable-lastfm \
	--enable-mms \
	--enable-oggflac \
	--enable-pipe-output \
	--enable-recorder-output \
	--disable-shout \
	--enable-sndfile \
	--enable-vorbis \
	--disable-vorbis-encoder \
	--with-faad="$(STAGING_DIR)/usr" \
	--with-tremor=yes \

endif

ifeq ($(BUILD_VARIANT),mini)

  # oggflac is not compatible with tremor
  CONFIGURE_ARGS += \
	--disable-upnp \
	--disable-aac \
	--disable-audiofile \
	--disable-fifo \
	--disable-ffmpeg \
	--disable-id3 \
	--disable-mms \
	--disable-pipe-output \
	--disable-recorder-output \
	--disable-shout \
	--disable-sndfile \
	--disable-vorbis \
	--disable-vorbis-encoder \
	--with-tremor=yes \

endif

define Package/mpd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mpd $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/doc/mpdconf.example $(1)/etc/mpd.conf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mpd.init $(1)/etc/init.d/mpd
endef

define Package/mpd-full/install
$(call Package/mpd/install,$1)
endef

define Package/mpd-mini/install
$(call Package/mpd/install,$1)
endef

define Package/mpd-avahi-service/install
	$(INSTALL_DIR) $(1)/etc/avahi/services
	$(INSTALL_DATA) ./files/mpd.service $(1)/etc/avahi/services/
endef

$(eval $(call BuildPackage,mpd-full))
$(eval $(call BuildPackage,mpd-mini))
$(eval $(call BuildPackage,mpd-avahi-service))
