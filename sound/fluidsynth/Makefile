include $(TOPDIR)/rules.mk

PKG_NAME:=fluidsynth
PKG_VERSION:=2.5.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/FluidSynth/fluidsynth/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=72f5720328fe44e2e5c67813885f0a6b4b004d048bd2eeeb0c0064074ebff530

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:fluidsynth:fluidsynth

# fluidsynth >= 2.5 build-depends on the gcem header-only constexpr math
# library; the OpenWrt 'gcem' package installs its headers and CMake
# config files into staging so find_package(GCEM) resolves there.
PKG_BUILD_DEPENDS:=gcem

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/nls.mk

CMAKE_INSTALL:=1

CMAKE_OPTIONS += \
	-Denable-coverage=off \
	-Denable-floats=off \
	-Denable-fpe-check=off \
	-Denable-portaudio=off \
	-Denable-profiling=off \
	-Denable-trap-on-fpe=off \
	-Denable-ubsan=off \
	-Denable-alsa=on \
	-Denable-aufile=off \
	-DBUILD_SHARED_LIBS=on \
	-Denable-dbus=off \
	-Denable-ipv6=off \
	-Denable-jack=off \
	-Denable-ladspa=off \
	-Denable-libinstpatch=off \
	-Denable-libsndfile=on \
	-Denable-midishare=off \
	-Denable-opensles=off \
	-Denable-oboe=off \
	-Denable-network=off \
	-Denable-oss=off \
	-Denable-dsound=off \
	-Denable-wasapi=off \
	-Denable-waveout=off \
	-Denable-winmidi=off \
	-Denable-sdl2=off \
	-Denable-sdl3=off \
	-Denable-pulseaudio=off \
	-Denable-pipewire=off \
	-Denable-readline=off \
	-Denable-threads=off \
	-Denable-openmp=off \
	-Denable-systemd=off \
	-Denable-coreaudio=off \
	-Denable-coremidi=off \
	-Denable-framework=off \
	-Denable-dart=off \
	-Denable-kai=off

define Package/libfluidsynth
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=A SoundFont Synthesizer
  URL:=https://www.fluidsynth.org
  DEPENDS:=+alsa-lib +glib2 +libsndfile +libstdcpp
endef

define Package/libfluidsynth/description
FluidSynth is a cross-platform, real-time software synthesizer based on the Soundfont 2 specification.
endef

define Package/libfluidsynth/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libfluidsynth))
