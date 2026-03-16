include $(TOPDIR)/rules.mk

PKG_NAME:=ttymidi-sysex
PKG_SOURCE_DATE:=2021-05-07
PKG_SOURCE_VERSION:=e519a1167253e24ae35caed0371fed5bd4f26061
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/cchaussat/ttymidi-sysex
PKG_MIRROR_HASH:=ae5f3f18dd4b7415a6f79b76f6d563713e86e88138b374cb0b3546e75738bad7

PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_BUILD_DEPENDS:=!USE_GLIBC:argp-standalone
PKG_BUILD_FLAGS:=lto

include $(INCLUDE_DIR)/package.mk

define Package/ttymidi-sysex
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=ttymidi (with full bi-di sysex support)
  URL:=https://github.com/cchaussat/ttymidi-sysex
  DEPENDS:=+alsa-lib
endef

define Package/ttymidi-sysex/description
ttymidi is a GPL-licensed program that allows external serial devices
to interface with ALSA MIDI applications. The main motivation behind
ttymidi was to make Arduino boards talk to MIDI applications without
the need to use (or build) any extra hardware. 
endef

TARGET_LDFLAGS += -lasound -Wl,--gc-sections,--as-needed

define Build/Configure
endef

define Build/Compile
	( cd $(PKG_BUILD_DIR) ; $(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(TARGET_LDFLAGS) -o ttymidi-sysex ttymidi-sysex.c $(if $(CONFIG_USE_GLIBC),,$(STAGING_DIR)/usr/lib/libargp.a) )
endef

define Package/ttymidi-sysex/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ttymidi-sysex $(1)/usr/bin/
	$(INSTALL_BIN) ./files/ttymidi-sysex.init $(1)/etc/init.d/ttymidi-sysex
	$(INSTALL_DATA) ./files/ttymidi-sysex.defaults $(1)/etc/uci-defaults/90-ttymidi-sysex
endef

$(eval $(call BuildPackage,ttymidi-sysex))
