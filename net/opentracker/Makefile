# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=opentracker
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://erdgeist.org/gitweb/opentracker
PKG_SOURCE_DATE:=2021-08-23
PKG_SOURCE_VERSION:=110868ec4ebe60521d5a4ced63feca6a1cf0aa2a
PKG_MIRROR_HASH:=02db684fa9b28952df4aa8de2a1d20ca840695b51103f0b6eb716a4ca370c5d7

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=Beerware

PKG_BUILD_DEPENDS:=libowfat

include $(INCLUDE_DIR)/package.mk

define Package/opentracker/Default
  SUBMENU:=BitTorrent
  SECTION:=net
  CATEGORY:=Network
  TITLE:=opentracker
  URL:=http://erdgeist.org/arts/software/opentracker/
  DEPENDS:=+zlib +libpthread
endef

define Package/opentracker
$(call Package/opentracker/Default)
  VARIANT:=ipv4
endef

define Package/opentracker6
$(call Package/opentracker/Default)
  TITLE+= (IPv6 build)
  VARIANT:=ipv6
endef


define Package/opentracker-default/description
 opentracker - An open and free bittorrent tracker

 opentracker is an open and free bittorrent tracker project.
 It aims for minimal resource usage and is intended to run at your wlan router.
 Currently it is deployed as an open and free tracker instance.
 Read our free and open tracker blog and announce your torrents there
 (but do not hesitate to setup your own free trackers!).
endef

define Package/opentracker/description
 $(call Package/opentracker-default/description)

 This package contains the IPv4-build of opentracker.

endef

define Package/opentracker6/description
 $(call Package/opentracker-default/description)

 This package contains the IPv6-build of opentracker.

endef


MAKE_FLAGS += PREFIX="$(STAGING_DIR)/usr"

ifeq ($(BUILD_VARIANT),ipv6)
  MAKE_FLAGS += FEATURES="-DWANT_V6"
endif

define Package/opentracker/conffiles
/etc/opentracker.conf
endef

define Package/opentracker6/conffiles
/etc/opentracker6.conf
endef

define Package/opentracker/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/opentracker $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/opentracker.conf.sample $(1)/etc/opentracker.conf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/opentracker.init $(1)/etc/init.d/opentracker
endef

define Package/opentracker6/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/opentracker $(1)/usr/bin/opentracker6
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/opentracker.conf.sample $(1)/etc/opentracker6.conf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/opentracker6.init $(1)/etc/init.d/opentracker6
endef

$(eval $(call BuildPackage,opentracker))
$(eval $(call BuildPackage,opentracker6))
