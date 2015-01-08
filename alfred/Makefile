#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

#
# The latest alfred git hash in PKG_REV can be obtained from http://git.open-mesh.org/alfred.git
#
PKG_NAME:=alfred
PKG_VERSION:=2014.4.0
PKG_RELEASE:=0
PKG_MD5SUM:=053cb5d9e7ca9384598e82944343dea2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://downloads.open-mesh.org/batman/releases/batman-adv-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

init-y := alfred

define Package/alfred
  URL:=http://www.open-mesh.org/
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A.L.F.R.E.D. - Almighty Lightweight Fact Remote Exchange Daemon
  DEPENDS:= +libc +IPV6:kmod-ipv6 +librt \
	  +ALFRED_NEEDS_lua:lua \
	  +ALFRED_NEEDS_libgps:libgps
endef

define Package/alfred/description
alfred is a user space daemon for distributing arbitrary local information over
the mesh/network in a decentralized fashion. This data can be anything which
appears to be useful - originally designed to replace the batman-adv
visualization (vis), you may distribute hostnames, phone books, administration
information, DNS information, the local weather forecast ...

alfred runs as daemon in the background of the system. A user may insert
information by using the alfred binary on the command line, or use special
programs to communicate with alfred (done via unix sockets). alfred then takes
care of distributing the local information to other alfred servers on other
nodes. This is done via IPv6 link-local multicast, and does not require any
configuration. A user can request data from alfred, and will receive the
information available from all alfred servers in the network.
endef

define Package/alfred/conffiles
/etc/config/alfred
endef

define Package/alfred/config
	source "$(SOURCE)/Config.in"
endef

MAKE_ALFRED_FLAGS=\
	CONFIG_ALFRED_VIS=$(if $(CONFIG_PACKAGE_ALFRED_VIS),y,n) \
	CONFIG_ALFRED_GPSD=$(if $(CONFIG_PACKAGE_ALFRED_GPSD),y,n)

TARGET_CFLAGS  += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections -fuse-linker-plugin

define Build/Compile
	CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) $(MAKE_ALFRED_FLAGS) all
endef

define Package/alfred/install
	$(INSTALL_DIR) $(1)/usr/sbin
	cp -fpR  $(PKG_BUILD_DIR)/alfred $(1)/usr/sbin/
	[ "x$(CONFIG_PACKAGE_ALFRED_VIS)" == "xy" ] && cp -fpR  $(PKG_BUILD_DIR)/vis/batadv-vis $(1)/usr/sbin/ ; true
	[ "x$(CONFIG_PACKAGE_ALFRED_GPSD)" == "xy" ] && cp -fpR  $(PKG_BUILD_DIR)/gpsd/alfred-gpsd $(1)/usr/sbin/ ; true
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/alfred.init $(1)/etc/init.d/alfred
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/alfred.config $(1)/etc/config/alfred
	$(INSTALL_DIR) $(1)/etc/alfred
	[ "x$(CONFIG_PACKAGE_ALFRED_BATHOSTS)" == "xy" ] && $(INSTALL_BIN) ./files/bat-hosts.lua $(1)/etc/alfred/bat-hosts.lua ; true
endef

$(eval $(call BuildPackage,alfred))
