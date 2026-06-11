# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=opentracker
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://erdgeist.org/gitweb/opentracker
PKG_SOURCE_DATE:=2026-05-26
PKG_SOURCE_VERSION:=1c7fac4cc23801ac81a2abd7d3110683831c4811
PKG_MIRROR_HASH:=091b87ecf0de75e89e3a52f2b773a4847951d5dd83f4013b32c03f34b9da415e

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=Beerware

PKG_BUILD_DEPENDS:=libowfat

include $(INCLUDE_DIR)/package.mk

define Package/opentracker
  SUBMENU:=BitTorrent
  SECTION:=net
  CATEGORY:=Network
  TITLE:=opentracker
  URL:=https://erdgeist.org/arts/software/opentracker/
  DEPENDS:=+zlib +libpthread
  PROVIDES:=opentracker6
endef

define Package/opentracker/description
 opentracker - An open and free bittorrent tracker

 opentracker is an open and free bittorrent tracker project.
 It aims for minimal resource usage and is intended to run at your wlan router.
 Currently it is deployed as an open and free tracker instance.
 Read our free and open tracker blog and announce your torrents there
 (but do not hesitate to setup your own free trackers!).

 opentracker now supports listening on both IPv4 and IPv6 at the same time.
endef

MAKE_FLAGS += PREFIX="$(STAGING_DIR)/usr"

TARGET_CFLAGS += -DWANT_NO_AUTO_FREE

define Package/opentracker/conffiles
/etc/opentracker.conf
endef

define Package/opentracker/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/opentracker $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/opentracker.conf.sample $(1)/etc/opentracker.conf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/opentracker.init $(1)/etc/init.d/opentracker
endef

$(eval $(call BuildPackage,opentracker))
