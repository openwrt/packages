include $(TOPDIR)/rules.mk

PKG_NAME:=rtpmidid
PKG_VERSION:=23.12
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/davidmoreno/rtpmidid
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=e787ce013fdc148c50b625a1c7d8adf99d9fee2a81d91e734af75828ed597099

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-3.0-or-later LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE.md LICENSE-lib.txt LICENSE-daemon.txt

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/rtpmidid
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=RTP MIDI User Space Driver Daemon for Linux
  URL:=https://github.com/davidmoreno/rtpmidid/
  DEPENDS:=+alsa-lib +libavahi-client +libfmt
endef

define Package/rtpmidid/description
rtpmidid is an user daemon, and when a RTP MIDI device is announced
using mDNS (also known as Zeroconf, Avahi, and multicast DNS) it
exposes this ALSA sequencer port.
endef

define Build/Install
endef

define Package/rtpmidid/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/rtpmidid $(1)/usr/bin/
	$(INSTALL_BIN) ./files/rtpmidid.init $(1)/etc/init.d/rtpmidid
endef

$(eval $(call BuildPackage,rtpmidid))
