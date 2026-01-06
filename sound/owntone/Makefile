#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=owntone
PKG_VERSION:=29.0
PKG_RELEASE:=1

# Release
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/owntone/owntone-server/releases/download/$(PKG_VERSION)/
PKG_HASH:=b9cbb9521aed06253b05902a8393a12cd0214d29a7f174855af9ff15a3742b0d

PKG_FIXUP:=autoreconf
PKG_BUILD_FLAGS:=no-mips16
PKG_INSTALL:=1

PKG_MAINTAINER:=Espen Jürgensen <espenjurgensen+openwrt@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_CONFIG_DEPENDS:= \
	CONFIG_AUDIO_SUPPORT

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/owntone
SECTION:=sound
CATEGORY:=Sound
TITLE:=iTunes (DAAP) server for Apple Remote and AirPlay
URL:=https://github.com/owntone/owntone-server
DEPENDS:=+libgpg-error +libgcrypt +libgdbm +zlib +libexpat +libunistring \
	+libevent2 +libevent2-pthreads +libdaemon +confuse +alsa-lib +libffmpeg-full \
	+libxml2 +libavahi-client +sqlite3-cli +libplist +libcurl +libjson-c \
	+libprotobuf-c +libgnutls +libsodium +libwebsockets +libuuid +libmount \
  +AUDIO_SUPPORT:pulseaudio \
	$(ICONV_DEPENDS)
endef

define Package/owntone/description
  OwnTone is a Linux/FreeBSD DAAP (iTunes), MPD (Music Player Daemon) and
  RSP (Roku) media server. It has support for AirPlay speakers, Chromecast,
  Apple Remote (and compatibles), MPD clients, Spotify, internet radio and
  LastFM. It does not support AirPlay/Chromecast video.
endef

define Package/owntone/conffiles
/etc/owntone.conf
endef

CONFIGURE_ARGS += \
	--enable-chromecast \
	--disable-install_systemd \
	--disable-install_conf_file \
	--disable-install_user \
	--with-alsa

ifeq ($(BUILD_VARIANT),pulseaudio)
  CONFIGURE_ARGS+= --with-pulseaudio
else
  CONFIGURE_ARGS+= --without-pulseaudio
endif

TARGET_CFLAGS += $(FPIC)

ifeq ($(BUILD_VARIANT),pulseaudio)
ifeq ($(CONFIG_AUDIO_SUPPORT),y)
	TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib/pulseaudio
endif
endif

define Package/owntone/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/owntone $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/owntone.conf $(1)/etc/owntone.conf
	$(INSTALL_DIR) $(1)/usr/lib/owntone
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/owntone/* $(1)/usr/lib/owntone/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/owntone.init $(1)/etc/init.d/owntone
	$(INSTALL_DIR) $(1)/usr/share/owntone
	$(CP) $(PKG_INSTALL_DIR)/usr/share/owntone/htdocs $(1)/usr/share/owntone
endef

$(eval $(call BuildPackage,owntone))
