# SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=snapcast
PKG_VERSION:=0.28.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/badaix/snapcast.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH=288325fc8b134502adb522711c18210794734675684cf5d8eba8a0a82778f6c9

PKG_MAINTAINER:=Szabolcs Hubai <szab.hu@gmail.com>, David Andreoletti <david@andreoletti.net>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:badaix:snapcast

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += -DBUILD_TESTS=OFF

define Package/snapcast/Default
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=Synchronous multiroom audio player
  DEPENDS:=+AUDIO_SUPPORT:alsa-lib +libavahi-client +libatomic +libogg +libflac +libopus +boost +libsoxr
  URL:=https://github.com/badaix/snapcast
endef

define Package/snapcast/description/Default
  Synchronous audio player
endef

define Package/snapcast
  $(call Package/snapcast/Default)
  TITLE+=packages
endef

define Package/snapcast/description
  $(call Package/snapcast/description/Default)
  Snapcast is a multi-room client-server audio player,
  where all clients are time synchronized with the server
  to play perfectly synced audio
endef

define Package/snapserver
  $(call Package/snapcast/Default)
  TITLE+=Snapserver
  DEPENDS+=+libvorbis
  HIDDEN:=1
endef

define Package/snapclient
  $(call Package/snapcast/Default)
  TITILE+=Snapclient
  DEPENDS+=+libvorbisidec
  HIDDEN:=1
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
  source "$(SOURCE)/Config.in"
endef

define Package/snapserver/conffiles
/etc/config/snapserver
/etc/snapserver.conf
endef

define Package/snapclient/conffiles
/etc/config/snapclient
endef

define Package/snapserver/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/snapserver $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/snapserver.init $(1)/etc/init.d/snapserver
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/server/etc/snapserver.conf $(1)/etc/snapserver.conf
endef

define Package/snapclient/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/snapclient $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/snapclient.init $(1)/etc/init.d/snapclient
endef

$(eval $(call BuildPackage,snapserver))
$(eval $(call BuildPackage,snapclient))
$(eval $(call BuildPackage,snapcast))
