include $(TOPDIR)/rules.mk

PKG_NAME:=pipewire
PKG_VERSION:=1.6.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://gitlab.freedesktop.org/pipewire/$(PKG_NAME)/-/archive/$(PKG_VERSION)
PKG_HASH:=0cde58c124825bad462b32ab79f9aa286ee7b113cc73a5cda923a4365e752657

PKG_MAINTAINER:=Mirko Vogt <mirko-openwrt@nanl.de>
# MIT, except (all in libpipewire): the ALSA card profile code and data
# taken from PulseAudio, two BlueZ headers of the bluez5 plugin and the
# LADSPA header (LGPL-2.1-or-later), and the Chromium OS biquad/crossover
# filters of audioconvert (BSD-3-Clause)
PKG_LICENSE:=MIT LGPL-2.1-or-later BSD-3-Clause
PKG_LICENSE_FILES:=COPYING LICENSE

PKG_BUILD_PARALLEL:=1
# glib2/host: gdbus-codegen, which generates the BlueZ D-Bus interface code of
# the bluez5 plugin
PKG_BUILD_DEPENDS:=PIPEWIRE_BLUETOOTH:glib2/host

# Optional features are individually selectable (see Package/pipewire/config).
# Listing the symbols here reconfigures and rebuilds the package whenever any of
# them is toggled.
PKG_CONFIG_DEPENDS:= \
	CONFIG_PIPEWIRE_ALSA \
	CONFIG_PIPEWIRE_PULSE \
	CONFIG_PIPEWIRE_PULSE_TUNNEL \
	CONFIG_PIPEWIRE_UDEV \
	CONFIG_PIPEWIRE_DBUS \
	CONFIG_PIPEWIRE_BLUETOOTH \
	CONFIG_PIPEWIRE_BLUETOOTH_AAC \
	CONFIG_PIPEWIRE_BLUETOOTH_LDAC \
	CONFIG_PIPEWIRE_BLUETOOTH_APTX \
	CONFIG_PIPEWIRE_BLUETOOTH_OPUS \
	CONFIG_PIPEWIRE_RAOP \
	CONFIG_PIPEWIRE_AVAHI \
	CONFIG_PIPEWIRE_V4L2 \
	CONFIG_PIPEWIRE_FFMPEG \
	CONFIG_PIPEWIRE_SNDFILE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

# Compile out the Valgrind client requests of the bundled valgrind.h: they
# have no use on OpenWrt targets, and their 32-bit MIPS assembly cannot be
# assembled in MIPS16 mode.
TARGET_CFLAGS += -DNVALGRIND

define Package/libpipewire
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=PipeWire client library, modules and SPA plugins
  URL:=https://pipewire.org
  # Every optional feature adds its dep only when the matching config symbol
  # (Package/pipewire/config) is set; the modules and SPA plugins linking
  # these libraries are part of this package.
  DEPENDS:= \
	$(ATOMIC64_DEPENDS) \
	+PIPEWIRE_ALSA:alsa-lib \
	+PIPEWIRE_PULSE_TUNNEL:libpulse \
	+PIPEWIRE_UDEV:libudev-zero \
	+PIPEWIRE_DBUS:libdbus \
	+PIPEWIRE_BLUETOOTH:glib2 \
	+PIPEWIRE_BLUETOOTH:bluez-libs \
	+PIPEWIRE_BLUETOOTH:libusb-1.0 \
	+PIPEWIRE_BLUETOOTH:sbc \
	+PIPEWIRE_BLUETOOTH_AAC:fdk-aac \
	+PIPEWIRE_BLUETOOTH_LDAC:libldac \
	+PIPEWIRE_BLUETOOTH_APTX:libfreeaptx \
	+PIPEWIRE_BLUETOOTH_OPUS:libopus \
	+PIPEWIRE_RAOP:libopenssl \
	+PIPEWIRE_AVAHI:libavahi-client \
	+PIPEWIRE_FFMPEG:ffmpeg \
	+PIPEWIRE_SNDFILE:libsndfile
endef

define Package/libpipewire/description
  The PipeWire client library libpipewire, together with the PipeWire modules,
  the SPA plugins, the ALSA card profile data and the client configuration.
  These are loaded by every PipeWire process: the pipewire daemon, the session
  manager and all clients.
endef

define Package/libpipewire/conffiles
/etc/pipewire/client.conf.d/20-openwrt-rt.conf
endef

define Package/pipewire
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=PipeWire multimedia server (minimal)
  URL:=https://pipewire.org
  LICENSE:=MIT
  # audio-support: provides the audio, audio-capture and midi groups and puts
  # the ALSA devices into them; alsa-lib for the pipewire-alsa plugin
  DEPENDS:=audio-support +libpipewire +PIPEWIRE_ALSA:alsa-lib
  # supplementary groups for access to the ALSA playback, capture and MIDI
  # devices; procd applies them (initgroups()) when dropping privileges to
  # the pipewire user
  USERID:=pipewire:pipewire:audio=29,audio-capture=32,midi=55
endef

define Package/pipewire/description
  PipeWire multimedia server, running as a single system-wide instance under
  the dedicated pipewire user. Optional features (the PulseAudio compatible
  server, Bluetooth, udev, D-Bus, RAOP, Avahi, V4L2, FFmpeg and libsndfile) are
  selectable individually; the default selection is ALSA, udev and the
  PulseAudio compatible server. No session manager is built: install
  wireplumber. JACK, GStreamer and systemd support are not built. Every meson
  option is set explicitly.
endef

define Package/pipewire/conffiles
/etc/pipewire/pipewire.conf.d/20-openwrt-rt.conf
$(if $(CONFIG_PIPEWIRE_PULSE),/etc/pipewire/pipewire-pulse.conf.d/20-openwrt-rt.conf)
endef

# Only dependency-bearing feature switches are exposed here; every other upstream
# meson option stays pinned explicitly in MESON_ARGS (no 'auto', for reproducible
# builds). The symbols do not depend on PACKAGE_* and are grouped in a menu:
# several dependencies carry a non-selecting dependency (alsa-lib ->
# audio-support, libudev-zero -> libevdev -> input-support, ffmpeg ->
# @FFMPEG_PROGRAMS, ...), which the generator folds onto the depending package
# (libpipewire, pipewire) as 'depends on !(SYM) || DEP'; making SYM depend on
# that package would close a Kconfig recursion. The defaults select ALSA, udev
# and pipewire-pulse.
define Package/pipewire/config
	menu "PipeWire feature selection"

config PIPEWIRE_ALSA
	bool "ALSA backend + pipewire-alsa plugin"
	default y
	help
		Native ALSA capture and playback, and the pipewire-alsa
		plugin for ALSA applications.

config PIPEWIRE_PULSE
	bool "PulseAudio-compatible server (pipewire-pulse)"
	default y
	help
		Install and run the pipewire-pulse server, so PulseAudio
		clients work unmodified. module-protocol-pulse is always
		built; this option controls the pipewire-pulse binary
		and its init script.

config PIPEWIRE_PULSE_TUNNEL
	bool "PulseAudio tunnel module (connection to a remote server)"
	default n
	help
		module-pulse-tunnel, which connects this PipeWire
		instance as a client to a remote PulseAudio or
		pipewire-pulse server. It is the only part of PipeWire
		that links the libpulse client library.

config PIPEWIRE_UDEV
	bool "udev device enumeration"
	default y
	help
		Enumerate ALSA and V4L2 devices through udev, provided
		by libudev-zero. libudev-zero reports devices added at
		runtime only if kernel uevents are rebroadcast to it.

config PIPEWIRE_DBUS
	bool "D-Bus support"
	default n
	help
		D-Bus client support, required for Bluetooth. Needs a
		running D-Bus daemon.

config PIPEWIRE_BLUETOOTH
	bool "Bluetooth audio (bluez5: A2DP/HSP/HFP)"
	default n
	select PIPEWIRE_DBUS
	help
		Bluetooth audio through the bluez5 SPA plugin, with the
		SBC codec always included. Enables D-Bus support. Needs
		bluetoothd and the D-Bus daemon running, and a session
		manager with its Bluetooth monitor enabled.

config PIPEWIRE_BLUETOOTH_AAC
	bool "Bluetooth AAC codec"
	depends on PIPEWIRE_BLUETOOTH
	# No BUILD_PATENTED dependency: without BUILD_PATENTED, fdk-aac is
	# built without SBR, USAC and MPEG Surround (patches-free, the
	# changes of Fedora's fdk-aac-free), which still covers the AAC-LC
	# profile used by A2DP. Fedora builds this codec against that
	# variant.
	default y
	help
		MPEG-2/4 AAC codec for A2DP, using fdk-aac. Without
		BUILD_PATENTED, fdk-aac is built without SBR, USAC and
		MPEG Surround; the AAC-LC profile used by A2DP remains.

config PIPEWIRE_BLUETOOTH_LDAC
	bool "Bluetooth LDAC codec (encoder)"
	depends on PIPEWIRE_BLUETOOTH
	# libldac is little-endian only. Its @!BIG_ENDIAN alone would leave
	# this option visible and make libpipewire unselectable when enabled.
	depends on !BIG_ENDIAN
	# No BUILD_PATENTED dependency: libldac is part of AOSP
	# (Apache-2.0) and is shipped by Debian (main) and Fedora.
	default n
	help
		Sony LDAC codec for A2DP at up to 990 kbps. Encoding
		only; there is no open-source LDAC decoder.

config PIPEWIRE_BLUETOOTH_APTX
	bool "Bluetooth aptX / aptX HD codec"
	depends on PIPEWIRE_BLUETOOTH
	# No BUILD_PATENTED dependency: of the aptX patents, EP 0400755B1
	# and US 9398620B1 have expired and EP 0398973B1 was revoked, and
	# Debian ships libfreeaptx in main. Fedora's legal review found the
	# patent status unclear (rhbz#1908922), so Fedora provides aptX
	# only through RPM Fusion. aptX is a trademark of Qualcomm.
	default n
	help
		Qualcomm aptX, aptX HD and aptX Low Latency codecs for
		A2DP, using libfreeaptx.

config PIPEWIRE_BLUETOOTH_OPUS
	bool "Bluetooth Opus codec"
	depends on PIPEWIRE_BLUETOOTH
	default y
	help
		Opus codec for A2DP. This option also enables Opus
		support in the RTP and RAOP network modules.

config PIPEWIRE_RAOP
	bool "RAOP / AirPlay sink"
	default n
	help
		Sink module for streaming to AirPlay (RAOP) receivers.

config PIPEWIRE_AVAHI
	bool "Avahi / zeroconf discovery"
	default n
	help
		Discovery and announcement of network audio services
		over mDNS (zeroconf), using Avahi.

config PIPEWIRE_V4L2
	bool "Video4Linux2 capture"
	default n
	help
		V4L2 SPA plugin and the pipewire-v4l2 compatibility
		library.

config PIPEWIRE_FFMPEG
	bool "FFmpeg SPA plugin"
	default n
	help
		FFmpeg based SPA plugin for additional codecs and
		formats.

config PIPEWIRE_SNDFILE
	bool "libsndfile support (pw-cat, filter-chain file I/O)"
	default n
	help
		Sound file input and output for pw-cat and
		module-filter-chain.
	endmenu
endef

MESON_ARGS += \
	-Ddocs=disabled \
	-Dman=disabled \
	-Dexamples=disabled \
	-Dtests=disabled \
	-Dinstalled_tests=disabled \
	-Dgstreamer=disabled \
	-Dgstreamer-device-provider=disabled \
	-Dlibsystemd=disabled \
	-Dlogind=disabled \
	-Dlogind-provider=libsystemd \
	-Dsystemd-system-service=disabled \
	-Dsystemd-user-service=disabled \
	-Dselinux=disabled \
	-Dpipewire-alsa=$(if $(CONFIG_PIPEWIRE_ALSA),enabled,disabled) \
	-Dpipewire-jack=disabled \
	-Dpipewire-v4l2=$(if $(CONFIG_PIPEWIRE_V4L2),enabled,disabled) \
	-Djack-devel=false \
	-Dlibjack-path='' \
	-Dlibv4l2-path='' \
	-Dspa-plugins=enabled \
	-Dalsa=$(if $(CONFIG_PIPEWIRE_ALSA),enabled,disabled) \
	-Daudiomixer=enabled \
	-Daudioconvert=enabled \
	-Dbluez5=$(if $(CONFIG_PIPEWIRE_BLUETOOTH),enabled,disabled) \
	-Dbluez5-backend-hsp-native=$(if $(CONFIG_PIPEWIRE_BLUETOOTH),enabled,disabled) \
	-Dbluez5-backend-hfp-native=$(if $(CONFIG_PIPEWIRE_BLUETOOTH),enabled,disabled) \
	-Dbluez5-backend-native-mm=disabled \
	-Dbluez5-backend-ofono=disabled \
	-Dbluez5-backend-hsphfpd=disabled \
	-Dbluez5-codec-aptx=$(if $(CONFIG_PIPEWIRE_BLUETOOTH_APTX),enabled,disabled) \
	-Dbluez5-codec-ldac=$(if $(CONFIG_PIPEWIRE_BLUETOOTH_LDAC),enabled,disabled) \
	-Dbluez5-codec-ldac-dec=disabled \
	-Dbluez5-codec-aac=$(if $(CONFIG_PIPEWIRE_BLUETOOTH_AAC),enabled,disabled) \
	-Dbluez5-codec-lc3plus=disabled \
	-Dbluez5-codec-opus=$(if $(CONFIG_PIPEWIRE_BLUETOOTH_OPUS),enabled,disabled) \
	-Dbluez5-codec-lc3=disabled \
	-Dbluez5-codec-g722=disabled \
	-Dbluez5-plc-spandsp=disabled \
	-Dcontrol=enabled \
	-Daudiotestsrc=disabled \
	-Dffmpeg=$(if $(CONFIG_PIPEWIRE_FFMPEG),enabled,disabled) \
	-Djack=disabled \
	-Dsupport=enabled \
	-Devl=disabled \
	-Dtest=disabled \
	-Dv4l2=$(if $(CONFIG_PIPEWIRE_V4L2),enabled,disabled) \
	-Ddbus=$(if $(CONFIG_PIPEWIRE_DBUS),enabled,disabled) \
	-Dlibcamera=disabled \
	-Dvideoconvert=disabled \
	-Dvideotestsrc=disabled \
	-Dvolume=disabled \
	-Dvulkan=disabled \
	-Dpw-cat=$(if $(CONFIG_PIPEWIRE_SNDFILE),enabled,disabled) \
	-Dpw-cat-ffmpeg=disabled \
	-Dudev=$(if $(CONFIG_PIPEWIRE_UDEV),enabled,disabled) \
	-Dsdl2=disabled \
	-Dsndfile=$(if $(CONFIG_PIPEWIRE_SNDFILE),enabled,disabled) \
	-Dlibmysofa=disabled \
	-Dlibpulse=$(if $(CONFIG_PIPEWIRE_PULSE_TUNNEL),enabled,disabled) \
	-Droc=disabled \
	-Davahi=$(if $(CONFIG_PIPEWIRE_AVAHI),enabled,disabled) \
	-Decho-cancel-webrtc=disabled \
	-Dlibusb=$(if $(CONFIG_PIPEWIRE_BLUETOOTH),enabled,disabled) \
	-Dsession-managers='[]' \
	-Draop=$(if $(CONFIG_PIPEWIRE_RAOP),enabled,disabled) \
	-Dlv2=disabled \
	-Dx11=disabled \
	-Dx11-xfixes=disabled \
	-Dlibcanberra=disabled \
	-Dlegacy-rtkit=false \
	-Davb=disabled \
	-Dflatpak=disabled \
	-Dreadline=disabled \
	-Dgsettings=disabled \
	-Dcompress-offload=disabled \
	-Dpam-defaults-install=false \
	-Dpam-memlock-default=8192 \
	-Drlimits-install=false \
	-Drlimits-match='@pipewire' \
	-Drtprio-server=88 \
	-Drtprio-client=83 \
	-Drlimits-rtprio=95 \
	-Drlimits-memlock=4194304 \
	-Drlimits-nice=-19 \
	-Dopus=$(if $(CONFIG_PIPEWIRE_BLUETOOTH_OPUS),enabled,disabled) \
	-Dlibffado=disabled \
	-Dgsettings-pulse-schema=disabled \
	-Dsnap=disabled \
	-Debur128=disabled \
	-Dfftw=disabled \
	-Donnxruntime=disabled

# Remaining meson_options.txt entries, set to their upstream defaults so that
# every option is explicit. resampler-precomp-tuples selects the resampler
# coefficients precomputed at build time (conversions between 32, 44.1 and
# 48 kHz). The rest are installation paths and documentation strings, without
# effect in this build (docs and systemd are disabled).
MESON_ARGS += \
	-Dresampler-precomp-tuples="['32000,44100','32000,48000','48000,44100','44100,48000']" \
	-Ddocdir=/usr/share/doc/pipewire \
	-Ddoc-prefix-value='' \
	-Ddoc-sysconfdir-value='' \
	-Dudevrulesdir=/lib/udev/rules.d \
	-Dsystemd-system-unit-dir=/usr/lib/systemd/system \
	-Dsystemd-user-unit-dir=/usr/lib/systemd/user

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/pipewire-0.3 $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/spa-0.2 $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/lib*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libpipewire/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpipewire-0.3.so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pipewire-0.3 $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/spa-0.2 $(1)/usr/lib/

	# bluez5 plugin data (Bluetooth hardware quirks database)
	$(if $(CONFIG_PIPEWIRE_BLUETOOTH),$(INSTALL_DIR) $(1)/usr/share/spa-0.2)
	$(if $(CONFIG_PIPEWIRE_BLUETOOTH),$(CP) $(PKG_INSTALL_DIR)/usr/share/spa-0.2/bluez5 $(1)/usr/share/spa-0.2/)

	# ALSA card profile (ACP) data: mixer paths and profile sets, from which
	# the ALSA plugin builds the profiles of each card, including the digital
	# (IEC958, HDMI) passthrough profiles.
	$(if $(CONFIG_PIPEWIRE_ALSA),$(INSTALL_DIR) $(1)/usr/share/alsa-card-profile)
	$(if $(CONFIG_PIPEWIRE_ALSA),$(CP) $(PKG_INSTALL_DIR)/usr/share/alsa-card-profile/* $(1)/usr/share/alsa-card-profile/)

	# client configuration, read by every libpipewire client
	$(INSTALL_DIR) $(1)/usr/share/pipewire
	$(CP) $(PKG_INSTALL_DIR)/usr/share/pipewire/client.conf $(1)/usr/share/pipewire/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/pipewire/client.conf.avail $(1)/usr/share/pipewire/

	# realtime settings for clients, which load module-rt as well (see
	# files/20-openwrt-rt.conf)
	$(INSTALL_DIR) $(1)/etc/pipewire/client.conf.d
	$(INSTALL_DATA) ./files/20-openwrt-rt.conf $(1)/etc/pipewire/client.conf.d/20-openwrt-rt.conf
endef

define Package/pipewire/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/pipewire $(1)/usr/bin/

	# pipewire-alsa plugin and its PCM/CTL definitions; alsa-lib reads
	# /etc/alsa/conf.d, not the /usr/share/alsa/alsa.conf.d upstream installs to
	$(if $(CONFIG_PIPEWIRE_ALSA),$(INSTALL_DIR) $(1)/usr/lib)
	$(if $(CONFIG_PIPEWIRE_ALSA),$(CP) $(PKG_INSTALL_DIR)/usr/lib/alsa-lib $(1)/usr/lib/)
	$(if $(CONFIG_PIPEWIRE_ALSA),$(INSTALL_DIR) $(1)/etc/alsa/conf.d)
	$(if $(CONFIG_PIPEWIRE_ALSA),$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/alsa/alsa.conf.d/50-pipewire.conf $(1)/etc/alsa/conf.d/)

	# daemon configuration; client.conf* is part of libpipewire
	$(INSTALL_DIR) $(1)/usr/share/pipewire
	$(CP) $(PKG_INSTALL_DIR)/usr/share/pipewire/* $(1)/usr/share/pipewire/
	$(RM) -r $(1)/usr/share/pipewire/client.conf $(1)/usr/share/pipewire/client.conf.avail

	$(INSTALL_DIR) $(1)/etc/pipewire/pipewire.conf.d
	# realtime settings for the daemon (see files/20-openwrt-rt.conf); the
	# client side is part of libpipewire
	$(INSTALL_DATA) ./files/20-openwrt-rt.conf $(1)/etc/pipewire/pipewire.conf.d/20-openwrt-rt.conf

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/pipewire.init $(1)/etc/init.d/pipewire

	# files/pipewire-hotplug (code commented out, not installed) outlines
	# restarting the stack when a sound card is added or removed, as
	# libudev-zero reports no hotplug events to the session manager

	# pipewire-pulse (PulseAudio-compatible server) is optional
	$(if $(CONFIG_PIPEWIRE_PULSE),$(CP) $(PKG_INSTALL_DIR)/usr/bin/pipewire-pulse $(1)/usr/bin/)
	$(if $(CONFIG_PIPEWIRE_PULSE),$(INSTALL_DIR) $(1)/etc/pipewire/pipewire-pulse.conf.d)
	$(if $(CONFIG_PIPEWIRE_PULSE),$(INSTALL_DATA) ./files/20-openwrt-rt.conf $(1)/etc/pipewire/pipewire-pulse.conf.d/20-openwrt-rt.conf)
	$(if $(CONFIG_PIPEWIRE_PULSE),$(INSTALL_BIN) ./files/pipewire-pulse.init $(1)/etc/init.d/pipewire-pulse)

	# D-Bus system policy for the pipewire user's access to BlueZ; not
	# installed: the default policies (system.conf, BlueZ's bluetooth.conf)
	# appear to allow this already, to be confirmed on hardware
	#$(if $(CONFIG_PIPEWIRE_BLUETOOTH),$(INSTALL_DIR) $(1)/etc/dbus-1/system.d)
	#$(if $(CONFIG_PIPEWIRE_BLUETOOTH),$(INSTALL_DATA) ./files/pipewire-bluez.dbus.conf $(1)/etc/dbus-1/system.d/pipewire-bluez.conf)
endef

define Package/pipewire-tools
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=PipeWire command-line tools (pw-*)
  URL:=https://pipewire.org
  LICENSE:=MIT
  # They link libpipewire; pw-top additionally links ncurses (libncursesw.so)
  # for its terminal UI.
  DEPENDS:=+libpipewire +libncurses
endef

define Package/pipewire-tools/description
  The PipeWire command-line utilities: pw-cli, pw-dump, pw-mon, pw-top, pw-link,
  pw-metadata, pw-loopback, pw-config, pw-dot, pw-profiler, ... - and the
  pw-cat family (pw-cat/pw-play/pw-record/pw-midi*), which is only present when
  the pipewire package is built with libsndfile support (PIPEWIRE_SNDFILE).
  They are packaged separately, so that images can leave them out.
endef

define Package/pipewire-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	# all pw-* utilities of this build; $(CP) preserves the pw-play/pw-record ->
	# pw-cat symlinks
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/pw-* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libpipewire))
$(eval $(call BuildPackage,pipewire))
$(eval $(call BuildPackage,pipewire-tools))
