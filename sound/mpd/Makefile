#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mpd
PKG_VERSION:=0.20.9
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://www.musicpd.org/download/mpd/0.20/
PKG_HASH:=cd77a2869e32354b004cc6b34fcb0bee56114caa2d9ed862aaa8071441e34eb7
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_IPV6 \

PKG_INSTALL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/mpd/Default
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=Music Player Daemon
  URL:=http://www.musicpd.org/
  DEPENDS:= +zlib +libcurl +libpthread +libmpdclient +libstdcpp $(ICONV_DEPENDS) \
	    +AUDIO_SUPPORT:alsa-lib +boost +boost-container +libexpat
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
  DEPENDS+= +libffmpeg +libid3tag +libmms +libupnp +libshout
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
  DEPENDS+= +libflac +libmpg123 +libvorbisidec
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

EXTRA_LDFLAGS += $(if $(ICONV_FULL),-liconv,-Wl,--whole-archive -liconv -Wl,--no-whole-archive)
EXTRA_CXXFLAGS += $(if $(CONFIG_GCC_VERSION_4_8),-std=gnu++11,-std=gnu++14)

CONFIGURE_ARGS += \
	$(call autoconf_bool,CONFIG_IPV6,ipv6) \
	--disable-debug \
	--disable-documentation \
	--disable-test \
	--disable-aac \
	--disable-adplug \
	--disable-ao \
	--disable-audiofile \
	--disable-bzip2 \
	--disable-cdio-paranoia \
	--disable-fluidsynth \
	--disable-wildmidi \
	--disable-gme \
	--enable-inotify \
	--disable-icu \
	--enable-iconv \
	--disable-iso9660 \
	--disable-jack \
	--disable-roar \
	--disable-libwrap \
	--disable-lsr \
	--disable-mad \
	--disable-mikmod \
	--disable-modplug \
	--disable-mpc \
	--disable-nfs \
	--disable-openal \
	--disable-opus \
	--disable-pulse \
	--disable-sidplay \
	--disable-smbclient \
	--disable-sndfile \
	--disable-solaris-output \
	--disable-sqlite \
	--disable-systemd-daemon \
	--disable-lame-encoder \
	--disable-twolame-encoder \
	--disable-shine-encoder \
	--disable-vorbis-encoder \
	--enable-wave-encoder \
	--disable-wavpack \
	--disable-webdav \
	--disable-wildmidi \
	--disable-zzip \
	--with-zeroconf=no \
	--disable-soxr \
	--enable-curl \
	--enable-httpd-output \
	$(call autoconf_bool,CONFIG_AUDIO_SUPPORT,alsa) \
	--enable-tcp \
	--disable-sndio \
	--disable-haiku


ifeq ($(BUILD_VARIANT),full)

  CONFIGURE_ARGS += \
	--enable-upnp \
	--enable-ffmpeg \
	--disable-flac \
	--enable-id3 \
	--enable-mms \
	--disable-mpg123 \
	--enable-pipe-output \
	--enable-recorder-output \
	--enable-shout \
	--disable-vorbis
endif

ifeq ($(BUILD_VARIANT),mini)

  # oggflac is not compatible with tremor
  CONFIGURE_ARGS += \
	--disable-upnp \
	--disable-fifo \
	--disable-ffmpeg \
	--disable-id3 \
	--disable-mms \
	--disable-shout \
	--enable-vorbis \
	--with-tremor=yes \
	--disable-recorder-output
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
