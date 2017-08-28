#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=espeak
PKG_VERSION:=1.48.04
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-source.zip
PKG_SOURCE_URL:=@SF/espeak
PKG_HASH:=bf9a17673adffcc28ff7ea18764f06136547e97bbd9edf2ec612f09b207f0659

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=License.txt
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-source
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/espeak
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+libpthread +libstdcpp +portaudio
  TITLE:=Speech synthesizer
  URL:=http://espeak.sourceforge.net/
endef

define Package/espeak/description
 eSpeak is a compact open source software speech synthesizer for English and
 other languages.
endef

MAKE_FLAGS+= \
	AUDIO="portaudio" \
	DATADIR="/usr/share/espeak" \
	CXXFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \

MAKE_PATH:=./src

define Package/espeak/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/espeak $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libespeak.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/share
	$(CP) $(PKG_INSTALL_DIR)/usr/share/espeak $(1)/usr/share/
endef

$(eval $(call BuildPackage,espeak))
