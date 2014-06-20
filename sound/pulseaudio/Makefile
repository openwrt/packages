#
# Copyright (C) 2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pulseaudio
PKG_VERSION:=5.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://freedesktop.org/software/pulseaudio/releases/
PKG_MD5SUM:=c43749838612f4860465e83ed62ca38e

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=intltool/host

PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0

PKG_INSTALL = 1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

#TODO: split pulse into executable and library (or even better into several libraries since they're used as loadable modules, so not linked into)
define Package/pulseaudio/Default
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+libspeexdsp +libsndfile +libltdl +libpthread \
	+librt +alsa-lib +libjson +libopenssl +libwrap +libcap $(ICONV_DEPENDS) $(INTL_DEPENDS)
  TITLE:=Network sound server
  MAINTAINER:=Peter Wagner <tripolar@gmx.at>
  URL:=http://www.pulseaudio.org
  PROVIDES:=pulseaudio
endef

define Package/pulseaudio-daemon
  $(call Package/pulseaudio/Default)
  VARIANT:=noavahi
endef

define Package/pulseaudio-daemon-avahi
  $(call Package/pulseaudio/Default)
  DEPENDS+=+dbus +libavahi-client +avahi-daemon
  TITLE+= (avahi)
  VARIANT:=avahi
endef

define Package/pulseaudio/Default/description
  PulseAudio (formerly Polypaudio) is a cross-platform, networked sound server.
endef

define Package/pulseaudio-daemon/description
  $(call Package/pulseaudio/Default/description)
endef

define Package/pulseaudio-daemon-avahi/description
  $(call Package/pulseaudio/Default/description)
  This package is compiled against dbus and avahi.
endef

define Package/pulseaudio-daemon/conffiles
/etc/pulse/client.conf
/etc/pulse/daemon.conf
/etc/pulse/default.pa
/etc/pulse/system.pa
endef

define Package/pulseaudio-daemon-avahi/conffiles
/etc/pulse/client.conf
/etc/pulse/daemon.conf
/etc/pulse/default.pa
/etc/pulse/system.pa
endef

define Package/pulseaudio-tools
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+libsndfile pulseaudio
  TITLE:=Tools for Pulseaudio
  URL:=http://www.pulseaudio.org
  VARIANT:=noavahi
endef

define Package/pulseaudio-profiles
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=pulseaudio
  TITLE:=Profiles for Pulseaudio
  URL:=http://www.pulseaudio.org
endef

CONFIGURE_ARGS += \
	--with-system-user=pulse \
	--with-system-group=pulse \
	--with-access-group=audio \
	--with-database=simple \
	--enable-alsa \
	--disable-hal \
	--disable-gconf \
	--disable-nls \
	--disable-manpages \
	--enable-oss-output \
	--disable-oss-wrapper \
	--disable-samplerate \
	--disable-per-user-esound-socket \
	--disable-solaris \
	--disable-gtk2 \
	--disable-glib2 \
	--disable-jack \
	--disable-asyncns \
	--disable-lirc \
	--disable-bluez \
	--disable-udev \
	--without-fftw

ifeq ($(BUILD_VARIANT),avahi)
CONFIGURE_ARGS += \
	--enable-avahi \
	--enable-dbus
endif

ifeq ($(BUILD_VARIANT),noavahi)
CONFIGURE_ARGS += \
	--disable-avahi \
	--disable-dbus
endif

CONFIGURE_VARS += \
	PKG_CONFIG_LIBDIR="$(STAGING_DIR)/usr/lib/pkgconfig"

#SUPP_LIBS:=-L$(INTL_PREFIX)/lib -L$(ICONV_PREFIX)/lib
TARGET_CFLAGS += -std=gnu99

define Build/InstallDev
	$(INSTALL_DIR) \
		$(1)/usr/lib/pkgconfig \
		$(1)/usr/include/pulse \
		$(1)/usr/lib \
		$(1)/usr/lib/pulseaudio
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/pulse/* \
		$(1)/usr/include/pulse
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc \
		$(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pulseaudio/* \
		$(1)/usr/lib/pulseaudio/
endef

define Package/pulseaudio-daemon/install
	$(INSTALL_DIR) \
		$(1)/etc/pulse \
		$(1)/etc/init.d \
		$(1)/usr/bin \
		$(1)/usr/lib \
		$(1)/usr/lib/pulseaudio \
		$(1)/usr/lib/pulse-$(PKG_VERSION)/modules

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/pulseaudio \
		$(1)/usr/bin/pulseaudio

	$(INSTALL_BIN) \
		./files/pulseaudio.init \
		$(1)/etc/init.d/pulseaudio

	$(INSTALL_CONF) \
		$(PKG_INSTALL_DIR)/etc/pulse/* \
		$(1)/etc/pulse

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib/

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pulseaudio/* \
		$(1)/usr/lib/pulseaudio/

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pulse-$(PKG_VERSION)/modules/lib*.so \
		$(1)/usr/lib/

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pulse-$(PKG_VERSION)/modules/module*.so \
		$(1)/usr/lib/pulse-$(PKG_VERSION)/modules/

	chmod -R 0644 $(1)/etc/pulse/*
endef

define Package/pulseaudio-daemon-avahi/install
	$(INSTALL_DIR) \
		$(1)/etc/pulse \
		$(1)/etc/init.d \
		$(1)/usr/bin \
		$(1)/usr/lib \
		$(1)/usr/lib/pulseaudio \
		$(1)/usr/lib/pulse-$(PKG_VERSION)/modules \
		$(1)/etc/dbus-1/system.d

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/pulseaudio \
		$(1)/usr/bin/pulseaudio

	$(INSTALL_BIN) \
		./files/pulseaudio.init \
		$(1)/etc/init.d/pulseaudio

	$(INSTALL_CONF) \
		$(PKG_INSTALL_DIR)/etc/pulse/* \
		$(1)/etc/pulse

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib/

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pulseaudio/* \
		$(1)/usr/lib/pulseaudio/

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pulse-$(PKG_VERSION)/modules/lib*.so \
		$(1)/usr/lib/

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pulse-$(PKG_VERSION)/modules/module*.so \
		$(1)/usr/lib/pulse-$(PKG_VERSION)/modules/

	$(INSTALL_CONF) \
		$(PKG_INSTALL_DIR)/etc/dbus-1/system.d/pulseaudio-system.conf \
		$(1)/etc/dbus-1/system.d/pulseaudio-system.conf

	chmod -R 0644 $(1)/etc/pulse/* $(1)/etc/dbus-1/system.d/pulseaudio-system.conf
endef

define Package/pulseaudio-tools/install
	$(INSTALL_DIR) \
		$(1)/usr/bin

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/pa* \
		$(1)/usr/bin/
endef

define Package/pulseaudio-profiles/install
	$(INSTALL_DIR) \
		$(1)/usr/share/pulseaudio/alsa-mixer/paths \
		$(1)/usr/share/pulseaudio/alsa-mixer/profile-sets

	$(INSTALL_CONF) \
		$(PKG_INSTALL_DIR)/usr/share/pulseaudio/alsa-mixer/paths/* \
		$(1)/usr/share/pulseaudio/alsa-mixer/paths

	$(INSTALL_CONF) \
		$(PKG_INSTALL_DIR)/usr/share/pulseaudio/alsa-mixer/profile-sets/* \
		$(1)/usr/share/pulseaudio/alsa-mixer/profile-sets
endef

$(eval $(call BuildPackage,pulseaudio-daemon))
$(eval $(call BuildPackage,pulseaudio-daemon-avahi))
$(eval $(call BuildPackage,pulseaudio-tools))
$(eval $(call BuildPackage,pulseaudio-profiles))
