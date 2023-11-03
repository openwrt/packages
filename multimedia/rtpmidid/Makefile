include $(TOPDIR)/rules.mk

PKG_NAME:=rtpmidid
PKG_RELEASE:=1

PKG_SOURCE_DATE:=2022-07-07
PKG_SOURCE_VERSION:=eab5cd80c5326c1b3720736442e1c2f7e2fa50d7
PKG_HASH:=b1bd7a28449bffb8e4cec3410c6e60a09abbfd19e84aed73c3d95c89c4d26a07

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/davidmoreno/rtpmidid/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_LICENSE:=GPL-3.0-or-later LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE.md LICENSE-lib.txt LICENSE-daemon.txt
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

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
