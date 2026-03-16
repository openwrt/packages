#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sox_ng
PKG_VERSION:=14.5.1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeberg.org/sox_ng/sox_ng/releases/download/$(PKG_NAME)-$(PKG_VERSION)
PKG_HASH:=1ebb6e6eedd1bb9a7b25bf54492f372d80c987f8f586d7e7cde69678889ff958

PKG_LICENSE:=GPL-2.0-only LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:sound_exchange_project:sound_exchange

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/sox_ng
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+lame-lib +libmad +libid3tag +libmagic \
		+libvorbis +alsa-lib +libflac +libopus +libopusfile +libwavpack
  TITLE:=Sox_ng is a general purpose sound converter/player/recorder
  URL:=https://codeberg.org/sox_ng/sox_ng
  PROVIDES:=sox
endef

define Package/sox_ng/description
  SoX_ng is a command line utility that can convert various formats
  of computer audio files in to other formats. It can also apply
  various effects to these sound files during the conversion.
  As an added bonus, SoX_ng can play and record audio files on
  several unix-style platforms.
endef

CONFIGURE_ARGS += \
		--without-oss \
		--without-ao \
		--with-alsa \
		--without-libltdl \
		--with-flac \
		--without-ladspa \
		--without-speexdsp \
		--without-png \
		--without-sndfile \
		--with-opus \
		--with-wavpack \
		--with-lame \
		--with-id3tag \
		--disable-openmp

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/opus

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsox_ng.{a,so*,la} $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
endef

define Package/sox_ng/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sox_ng $(1)/usr/bin/
	# Copy links
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/{play_ng,rec_ng,soxi_ng} $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsox_ng.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,sox_ng))
