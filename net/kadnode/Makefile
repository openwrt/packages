#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=kadnode
PKG_VERSION:=2.0.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/mwarning/KadNode.git
PKG_SOURCE_VERSION:=26dbc9436f8d2c68b899cd32e01bdbe1565294b2

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=67ba2ce03c3dd74b547885891391657aa9d6fae7c14558634776e1111e7cbe57
PKG_LICENSE:=MIT

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/kadnode
	SECTION:=net
	CATEGORY:=Network
	TITLE:=P2P DNS Resolver
	SUBMENU:=IP Addresses and Names
	URL:=https://github.com/mwarning/KadNode
	MENU:=1
	DEPENDS:=+KADNODE_ENABLE_BOB:libmbedtls +KADNODE_ENABLE_TLS:libmbedtls +KADNODE_ENABLE_UPNP:libminiupnpc +KADNODE_ENABLE_NATPMP:libnatpmp
	MAINTAINER:=Moritz Warning <moritzwarning@web.de>
endef

define Package/kadnode/description
	A P2P DNS system based on the BitTorrent network. It can be used as a decentralized DynDNS service.
endef

define Package/kadnode/config
	source "$(SOURCE)/Config.in"
endef

FEATURES = 

ifeq ($(CONFIG_KADNODE_ENABLE_CMD),y)
FEATURES += cmd
endif

ifeq ($(CONFIG_KADNODE_ENABLE_LPD),y)
FEATURES += lpd
endif

ifeq ($(CONFIG_KADNODE_ENABLE_TLS),y)
FEATURES += tls
endif

ifeq ($(CONFIG_KADNODE_ENABLE_BOB),y)
FEATURES += bob
endif

ifeq ($(CONFIG_KADNODE_ENABLE_DNS),y)
FEATURES += dns
endif

ifeq ($(CONFIG_KADNODE_ENABLE_UPNP),y)
FEATURES += upnp
endif

ifeq ($(CONFIG_KADNODE_ENABLE_NATPMP),y)
FEATURES += natpmp
endif

ifeq ($(CONFIG_KADNODE_ENABLE_DEBUG),y)
FEATURES += debug
endif

MAKE_FLAGS += FEATURES="$(FEATURES)"

define Package/kadnode/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/kadnode $(1)/usr/bin/
ifeq ($(CONFIG_KADNODE_ENABLE_CMD),y)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/kadnode-ctl $(1)/usr/bin/
endif
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/kadnode.init $(1)/etc/init.d/kadnode
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/kadnode.config $(1)/etc/config/kadnode
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) files/kadnode.postinst $(1)/etc/uci-defaults/99_kadnode
endef

$(eval $(call BuildPackage,kadnode))
