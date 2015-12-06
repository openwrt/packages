#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=udp-broadcast-relay
PKG_VERSION:=0.3
PKG_RELEASE:=5
PKG_MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
PKG_LICENSE:=GPL-2.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.joachim-breitner.de/udp-broadcast-relay/files/
PKG_MD5SUM:=a32f983b7063d6ac670e6b22be9b9d24

include $(INCLUDE_DIR)/package.mk

define Package/udp-broadcast-relay
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=listens for packets on a specified UDP broadcast port
  URL:=http://www.joachim-breitner.de/udp-broadcast-relay/
endef

define Package/udp-broadcast-relay/description
	This program listens for packets on a specified UDP broadcast port.
	When a packet is received, it sends that packet to all specified interfaces but
	the one it came from as though it originated from the original sender.
	The primary purpose of this is to allow games on machines on separated
	local networks (Ethernet, WLAN) that use udp broadcasts to find each other to do so.
	It also works on ppp links, so you can log in from windows boxes (e.g. using pptp)
	and play LAN-based games together. Currently, you have to care about upcoming or
	downgoing interfaces yourself.
endef

define Package/udp-broadcast-relay/conffiles
/etc/config/udp_broadcast_relay
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(PKG_BUILD_DIR)/main.c -o $(PKG_BUILD_DIR)/$(PKG_NAME)
endef

define Package/udp-broadcast-relay/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d
	$(CP) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/sbin/
	$(INSTALL_CONF) ./files/udp_broadcast_relay.config $(1)/etc/config/udp_broadcast_relay
	$(INSTALL_BIN) ./files/udp-broadcast-relay.init $(1)/etc/init.d/udp-broadcast-relay
endef

$(eval $(call BuildPackage,udp-broadcast-relay))
