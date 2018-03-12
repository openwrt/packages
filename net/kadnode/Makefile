#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk


PKG_NAME:=kadnode
PKG_VERSION:=2.2.0
PKG_RELEASE:=1


PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/mwarning/KadNode
PKG_SOURCE_VERSION:=c63e734950787d35c8bf1363448430942d1bb39d
PKG_MIRROR_HASH:=dcecfb14169ac5c4c28bcf147681f6823aa2d8a37d29d35ab3e76b613cce085c
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
	$(LN) /usr/bin/kadnode $(1)/usr/bin/kadnode-ctl
endif
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/kadnode.init $(1)/etc/init.d/kadnode
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/kadnode.config $(1)/etc/config/kadnode
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) files/kadnode.postinst $(1)/etc/uci-defaults/99_kadnode
endef

$(eval $(call BuildPackage,kadnode))
