#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ttyplay
PKG_VERSION:=0.1
PKG_RELEASE:=1
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENCE

PKG_SOURCE_URL:=https://github.com/koniu/ttyplay
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=4b6299854d85dcabb6141c6bf61b98f833a41d0a
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE).tar.xz

PKG_MAINTAINER:=koniu <koniu@riseup.net>

include $(INCLUDE_DIR)/package.mk

define Package/ttyplay
	SECTION:=sound
	CATEGORY:=Sound
	TITLE:=Play audio files out of the serial port
	DEPENDS:=+libsamplerate +libsndfile
	URL:=https://github.com/koniu/ttyplay
endef

define Package/ttyplay/description
	ttyplay takes a .wav file and plays it over the serial port. Combined
	with espeak and a little speaker wired into your serial headers it can
	be useful for playing (clever) messages to (unsuspecting) users.
endef

define Package/ttyplay/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ttyplay $(1)/usr/bin/
endef

$(eval $(call BuildPackage,ttyplay))
