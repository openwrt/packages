#
# Copyright (C) 2019 Álvaro Fernández Rojas <noltari@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=omxplayer
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/popcornmix/omxplayer.git
PKG_SOURCE_VERSION:=ecd446d2de7eb86a43acaae59807a8e5c173f80d
PKG_MIRROR_HASH:=03ccbd4b64944b417749aa5e2f3efad6bf5480efb52cdc4f51b4dcf490e5cd15

PKG_FLAGS:=nonshared

PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include/freetype2 \
	-I$(STAGING_DIR)/usr/include/dbus-1.0 \
	-I$(STAGING_DIR)/usr/lib/dbus-1.0/include

define Build/Prepare
	$(call Build/Prepare/Default,)
	$(CP) files/* $(PKG_BUILD_DIR)/
endef

define Package/omxplayer
  TITLE:=Raspberry Pi command line OMX player
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=@(TARGET_brcm2708_bcm2708||TARGET_brcm2708_bcm2709) \
	+brcm2708-userland +alsa-lib +libffmpeg-omx +libpcre +libdbus \
	+boost +boost-libs +libfreetype +libdbus \
	+dejavu-fonts-ttf-DejaVuSans +dejavu-fonts-ttf-DejaVuSans-Oblique
endef

define Package/omxplayer/description
  OMXPlayer is a command-line video player for the Raspberry Pi.
  It can play video directly from the command line and does not require a
  desktop.
  OMXPlayer leverages the OpenMAX API to make use of the hardware video
  decoder in the GPU. Hardware acceleration along with direct command-line
  use on ARM silicon allows ultra low overhead, low power video playback.
  OMXPlayer was developed as a testbed for the XBMC Raspberry Pi
  implementation and is quite handy to use standalone.
endef

define Package/omxplayer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/omxplayer.bin $(1)/usr/bin/omxplayer
endef

$(eval $(call BuildPackage,omxplayer))
