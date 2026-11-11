# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=opentracker
PKG_VERSION:=2.2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://erdgeist.org/arts/software/opentracker/
PKG_HASH:=be4318e50affa65000e80963a6d05245d32cd4b73875df19aeec2aeee81c8fc7

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=Beerware

include $(INCLUDE_DIR)/package.mk

define Package/opentracker
  SUBMENU:=BitTorrent
  SECTION:=net
  CATEGORY:=Network
  TITLE:=opentracker
  URL:=https://erdgeist.org/arts/software/opentracker/
  DEPENDS:=+zlib +libpthread +USE_MUSL:libbsd $(ATOMIC64_DEPENDS)
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

# Hardening and stripping follow the OpenWrt toolchain settings
MAKE_FLAGS += \
	HARDENING= \
	HARDENING_LD= \
	STRIP=:

# Skip opentracker.debug, as not needed and ignoring CFLAGS, causing build failure
MAKE_FLAGS += opentracker

# musl lacks arc4random(), use libbsd's
TARGET_LDFLAGS += $(if $(CONFIG_USE_MUSL),-lbsd)
# for non-native 64-bit atomics: link libatomic
TARGET_LDFLAGS += $(if $(CONFIG_HAS_ATOMIC64),,-latomic)

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
