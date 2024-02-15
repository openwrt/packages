#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mpd
PKG_VERSION:=0.23.15
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.musicpd.org/download/mpd/0.23
PKG_HASH:=550132239ad1acf82ccf8905b56cc13dc2c81a4489b96fba7731b3049907661a

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_CONFIG_DEPENDS:= \
	CONFIG_AUDIO_SUPPORT \
	CONFIG_BUILD_PATENTED \
	CONFIG_IPV6 \

PKG_BUILD_FLAGS:=no-mips16 no-lto

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/mpd/Default
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=Music Player Daemon
  URL:=https://www.musicpd.org/
  DEPENDS:= +zlib +libcurl +libpthread +libmpdclient +boost $(ICONV_DEPENDS) +libfmt \
            +AUDIO_SUPPORT:alsa-lib +libexpat +libflac +libid3tag +libfaad2 +libopus
  USERID:=mpd:mpd
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
  DEPENDS+= +AUDIO_SUPPORT:pulseaudio +libvorbis +libmms +libnpupnp +libshout +yajl \
            +libffmpeg +lame-lib +libsoxr +!BUILD_PATENTED:libmad
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
  DEPENDS+= +libmad +libvorbisidec
  PROVIDES:=mpd
  VARIANT:=mini
endef

define Package/mpd-mini/description
$(call Package/mpd/Default/description)
 .
 This package contains a minimal Music Player Daemon, with support for
 only FLAC, AAC, MP3 & OGG media types & only file: & http: protocols.
endef

define Package/mpd-mini/conffiles
/etc/mpd.conf
endef

define Package/mpd-avahi-service
$(call Package/mpd/Default)
  TITLE+= (Avahi service)
  DEPENDS+=+avahi-dbus-daemon
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

MESON_ARGS += \
	-Ddocumentation=disabled \
	-Dhtml_manual=false \
	-Dmanpages=false \
	-Dsyslog=enabled \
	-Dinotify=true \
	-Dio_uring=disabled \
	-Ddaemon=false \
	-Dsystemd=disabled \
	-Dtest=false \
	-Dfuzzer=false \
	-Depoll=true \
	-Deventfd=true \
	-Dsignalfd=true \
	-Dtcp=true \
	-Dipv6=$(if $(CONFIG_IPV6),en,dis)abled \
	-Dlocal_socket=true \
	-Ddsd=false \
	-Ddatabase=true \
	-Dlibmpdclient=enabled \
	-Dneighbor=false \
	-Dudisks=disabled \
	-Dwebdav=enabled \
	-Dcue=true \
	-Dcdio_paranoia=disabled \
	-Dcurl=enabled \
	-Dnfs=disabled \
	-Dsmbclient=disabled \
	-Dqobuz=disabled \
	-Dbzip2=disabled \
	-Diso9660=disabled \
	-Dzzip=disabled \
	-Did3tag=enabled \
	-Dchromaprint=disabled \
	-Dadplug=disabled \
	-Daudiofile=disabled \
	-Dfaad=enabled \
	-Dflac=enabled \
	-Dfluidsynth=disabled \
	-Dgme=disabled \
	-Dmikmod=disabled \
	-Dmodplug=disabled \
	-Dmpcdec=disabled \
	-Dmpg123=disabled \
	-Dopenmpt=disabled \
	-Dopus=enabled \
	-Dsidplay=disabled \
	-Dsndfile=disabled \
	-Dwavpack=disabled \
	-Dwildmidi=disabled \
	-Dvorbisenc=disabled \
	-Dlame=disabled \
	-Dtwolame=disabled \
	-Dshine=disabled \
	-Dwave_encoder=true \
	-Dlibsamplerate=disabled \
	-Dalsa=$(if $(CONFIG_AUDIO_SUPPORT),en,dis)abled \
	-Dao=disabled \
	-Dhttpd=true \
	-Djack=disabled \
	-Dopenal=disabled \
	-Doss=disabled \
	-Dpipewire=disabled \
	-Dsnapcast=false \
	-Dsndio=disabled \
	-Dsolaris_output=disabled \
	-Ddbus=disabled \
	-Dexpat=enabled \
	-Dicu=disabled \
	-Diconv=enabled \
	-Dpcre=disabled \
	-Dsqlite=disabled \
	-Dzlib=enabled \
	-Dzeroconf=disabled

ifeq ($(BUILD_VARIANT),full)

  MESON_ARGS += \
	-Dupnp=npupnp \
	-Dmms=enabled \
	-Dsoundcloud=enabled \
	-Dffmpeg=enabled \
	-Dmad=$(if $(CONFIG_BUILD_PATENTED),dis,en)abled \
	-Dtremor=disabled \
	-Dvorbis=enabled \
	-Dfifo=true \
	-Dpipe=true \
	-Dpulse=$(if $(CONFIG_AUDIO_SUPPORT),en,dis)abled \
	-Drecorder=true \
	-Dshout=enabled \
	-Dyajl=enabled \
	-Dvorbisenc=enabled \
	-Dlame=enabled \
	-Dsoxr=enabled

ifeq ($(CONFIG_AUDIO_SUPPORT),y)
	TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib/pulseaudio
endif
endif

ifeq ($(BUILD_VARIANT),mini)

  # oggflac is not compatible with tremor
  MESON_ARGS += \
	-Dupnp=disabled \
	-Dmms=disabled \
	-Dsoundcloud=disabled \
	-Dffmpeg=disabled \
	-Dmad=enabled \
	-Dtremor=enabled \
	-Dvorbis=disabled \
	-Dfifo=false \
	-Dpipe=false \
	-Dpulse=disabled \
	-Drecorder=false \
	-Dshout=disabled \
	-Dyajl=disabled \
	-Dsoxr=disabled
endif

define Package/mpd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mpd $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/doc/mpdconf.example $(1)/etc/mpd.conf
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
