#
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=chaosvpn

PKG_REV:=2eb24810b5aa0b2d56f21562e52927020dc3090a
PKG_VERSION:=2014-01-24
PKG_RELEASE=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ryd/chaosvpn.git
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_REV).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=Norbert Summer <git@o-g.at>

include $(INCLUDE_DIR)/package.mk

define Package/chaosvpn
		TITLE:=Config generator for chaos vpn
		SECTION:=net
		CATEGORY:=Network
		URL:=https://wiki.hamburg.ccc.de/index.php/ChaosVPN::DebianHowto
		SUBMENU:=VPN
		DEPENDS:=+tinc +ip +kmod-tun +libopenssl +zlib
endef

define Package/chaosvpn/description
		Configure tincd for the chaosvpn network
endef

define Package/chaosvpn/conffiles
/etc/tinc/chaosvpn.conf
endef

MAKE_FLAGS += \
		COPT="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(TARGET_LDFLAGS)"

define Package/chaosvpn/install
		$(INSTALL_DIR) $(1)/etc/tinc/chaos/ $(1)/usr/sbin/ $(1)/etc/init.d/ $(1)/etc/hotplug.d/iface/
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/chaosvpn $(1)/usr/sbin/
		$(INSTALL_BIN) ./files/chaosvpn.init $(1)/etc/init.d/chaosvpn
		$(INSTALL_BIN) ./files/chaosvpn.hotplug $(1)/etc/hotplug.d/iface/40-chaosvpn
		sed  -i -e 's/"\/sbin\/ip /"\/usr\/sbin\/ip /' $(PKG_BUILD_DIR)/chaosvpn.conf
		$(INSTALL_CONF) $(PKG_BUILD_DIR)/chaosvpn.conf $(1)/etc/tinc/chaosvpn.conf
endef

$(eval $(call BuildPackage,chaosvpn))

