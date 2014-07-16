#
# Copyright (C) 2007-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mpd
PKG_VERSION:=0.16.8
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.musicpd.org/download/mpd/0.16/
PKG_MD5SUM:=b412a9d0b3457bea1bb87904a8f80c04

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
  DEPENDS:= +glib2 +libcurl +libpthread \
	+libflac +BUILD_PATENTED:libmad +libvorbisidec
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
	+AUDIO_SUPPORT:alsa-lib \
	+libaudiofile +BUILD_PATENTED:libfaad2 +libffmpeg +libid3tag \
	+libmms +libogg +libshout +libsndfile +libvorbis
  PROVIDES:=mpd
  VARIANT:=full
endef

define Package/mpd-full/description
$(call Package/mpd/Default/description)
 .
 This package contains a full-blown Music Player Daemon.
endef

define Package/mpd-full/conffiles
/etc/avahi/services/mpd.service
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


CONFIGURE_ARGS += \
	$(call autoconf_bool,CONFIG_IPV6,ipv6) \
	--disable-debug \
	--disable-documentation \
	--disable-gprof \
	--disable-test \
	--disable-werror \
	\
	--disable-ao \
	--disable-bzip2 \
	--disable-cue \
	--disable-ffado \
	--disable-fluidsynth \
	--disable-gme \
	--disable-inotify \
	--disable-iso9660 \
	--disable-jack \
	--disable-lame-encoder \
	--disable-libwrap \
	--disable-lsr \
	--disable-mikmod \
	--disable-modplug \
	--disable-mpc \
	--disable-mpg123 \
	--disable-mvp \
	--disable-openal \
	--disable-pulse \
	--disable-sidplay \
	--disable-solaris-output \
	--disable-sqlite \
	--disable-twolame-encoder \
	--disable-wave-encoder \
	--disable-wavpack \
	--disable-wildmidi \
	--disable-zzip \
	--with-zeroconf=no \
	\
	--enable-curl \
	--enable-flac \
	--enable-httpd-output \
	$(call autoconf_bool,CONFIG_BUILD_PATENTED,mad) \
	$(call autoconf_bool,CONFIG_AUDIO_SUPPORT,oss) \
	--enable-tcp \
	--enable-un \

CONFIGURE_VARS += \
	FLAC_CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include/FLAC" \
	FLAC_LIBS="$(TARGET_LDFLAGS) -lFLAC" \
	$(if $(CONFIG_BUILD_PATENTED),MAD_CFLAGS="$(TARGET_CFLAGS)") \
	$(if $(CONFIG_BUILD_PATENTED),MAD_LIBS="$(TARGET_LDFLAGS) -lmad") \

TARGET_CFLAGS += -std=gnu99
TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib

# use gcc instead of g++ to avoid unnecessary linking against libstdc++
TARGET_CXX:=$(TARGET_CC)

ifeq ($(BUILD_VARIANT),full)

  CONFIGURE_ARGS += \
	$(call autoconf_bool,CONFIG_BUILD_PATENTED,aac) \
	$(call autoconf_bool,CONFIG_AUDIO_SUPPORT,alsa) \
	--enable-audiofile \
	--enable-fifo \
	--enable-ffmpeg \
	--enable-id3 \
	--enable-lastfm \
	--enable-mms \
	--enable-oggflac \
	--enable-pipe-output \
	--enable-recorder-output \
	--enable-shout \
	--enable-sndfile \
	--enable-vorbis \
	--enable-vorbis-encoder \
	--with-faad="$(STAGING_DIR)/usr" \
	--with-tremor=no \

endif

ifeq ($(BUILD_VARIANT),mini)

  # oggflac is not compatible with tremor
  CONFIGURE_ARGS += \
	--disable-aac \
	--disable-alsa \
	--disable-audiofile \
	--disable-fifo \
	--disable-ffmpeg \
	--disable-id3 \
	--disable-lastfm \
	--disable-mms \
	--disable-oggflac \
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
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mpd $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc
	$(CP) $(PKG_BUILD_DIR)/doc/mpdconf.example $(1)/etc/mpd.conf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mpd.init $(1)/etc/init.d/mpd
endef

define Package/mpd-full/install
$(call Package/mpd/install,$1)
	$(INSTALL_DIR) $(1)/etc/avahi/services
	$(INSTALL_DATA) ./files/mpd.service $(1)/etc/avahi/services/
endef

define Package/mpd-mini/install
$(call Package/mpd/install,$1)
endef

$(eval $(call BuildPackage,mpd-full))
$(eval $(call BuildPackage,mpd-mini))
