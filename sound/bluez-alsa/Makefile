#
# Copyright (C) 2017-2018 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bluez-alsa
PKG_VERSION:=20180615
PKG_RELEASE:=1
PKG_MAINTAINER:=
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

PKG_SOURCE_URL:=https://codeload.github.com/Arkq/$(PKG_NAME)/tar.gz/4a81de1?dummy=/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=3e91c85d31c7730c3383c194db101bc33a871b11aa92363514bf605bab91f4e2
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-4a81de1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/bluez-alsa
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+alsa-lib +bluez-daemon +glib2 +sbc +fdk-aac @LINUX_4_14
  TITLE:=Bluetooth Audio ALSA backend
  URL:=https://github.com/Arkq/bluez-alsa
endef

define Package/bluez-alsa/description
  ALSA plugin supporting Bluetooth audio
endef

CONFIGURE_ARGS += --enable-aac --disable-rfcomm

define Package/bluez-alsa/install
	$(INSTALL_DIR) $(1)/usr/share/alsa/alsa.conf.d/
	$(CP) $(PKG_BUILD_DIR)/src/asound/20-bluealsa.conf $(1)/usr/share/alsa/alsa.conf.d/
	$(INSTALL_DIR) $(1)/usr/lib/alsa-lib
	$(CP) $(PKG_BUILD_DIR)/src/asound/.libs/libasound_module_*_bluealsa.so $(1)/usr/lib/alsa-lib
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/bluealsa $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/bluealsa-aplay $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/bluealsa.init $(1)/etc/init.d/bluealsa
endef

$(eval $(call BuildPackage,bluez-alsa))
