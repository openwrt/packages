#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME := snapcast
PKG_VERSION := 0.27.0
PKG_RELEASE := $(PKG_SOURCE_VERSION)
PKG_USE_MIPS16 := 0

# PKG_MIRROR_HASH=skip
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/badaix/snapcast.git
PKG_SOURCE_VERSION:=v0.27.0
PKG_BUILD_DIR:=$(BUILD_DIR)/snapcast-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += -DBUILD_TESTS=OFF

define Package/snapcast/Default
	SECTION := sound
	CATEGORY := Sound
	TITLE := Synchronous multiroom audio player
	DEPENDS := +AUDIO_SUPPORT:alsa-lib +libstdcpp +libavahi-client +libatomic +libogg +libflac +libopus +boost +libsoxr
	URL := https://github.com/badaix/snapcast
endef

define Package/snapcast/description/Default
	Synchronous audio player
endef

define Package/snapcast
	$(call Package/snapcast/Default)
	TITLE += packages
endef

define Package/snapcast/description
	$(call Package/snapcast/description/Default)
	Snapcast is a multi-room client-server audio player, 
	where all clients are time synchronized with the server 
	to play perfectly synced audio
endef

define Package/snapserver
	$(call Package/snapcast/Default)
	TITLE += Snapserver
	DEPENDS += +AUDIO_SUPPORT:alsa-lib +libvorbis +libsoxr
	HIDDEN := 1
endef

define Package/snapclient
	$(call Package/snapcast/Default)
	TILE += Snapclient
	DEPENDS += +libvorbisidec +libsoxr
	HIDDEN := 1
endef

define Package/snapserver/description
	$(call Package/snapcast/description/Default)
	Snapcast server
endef

define Package/snapclient/description
	$(call Package/snapcast/description/Default)
	Snapcast client
endef

define Package/snapcast/config
 	menu "Select Snapcast Options"
		depends on PACKAGE_snapcast
		comment "Choose server or client"
		config PACKAGE_snapserver
			prompt "Snapserver"
			help
				Snapcast server
			default n

		config PACKAGE_snapclient
			prompt "Snapclient"
			help
				Snapcast client
			default y
	endmenu
endef

define Package/snapcast/Default/install
	true
endef

define Package/snapserver/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/snapserver $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/snapserver.init $(1)/etc/init.d/snapserver
	$(INSTALL_DIR) $(1)/etc/default
	$(INSTALL_BIN) $(CURDIR)/../../debian/snapserver.default $(1)/etc/default/snapserver
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/server/etc/snapserver.conf $(1)/etc/snapserver.conf
endef

define Package/snapclient/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/snapclient $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/snapclient.init $(1)/etc/init.d/snapclient
	$(INSTALL_DIR) $(1)/etc/default
	$(INSTALL_BIN) $(CURDIR)/../../debian/snapclient.default $(1)/etc/default/snapclient
endef

$(eval $(call BuildPackage,snapserver))
$(eval $(call BuildPackage,snapclient))
$(eval $(call BuildPackage,snapcast))
