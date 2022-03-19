# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=poemgr
PKG_SOURCE_DATE:=2022-03-19
PKG_SOURCE_VERSION:=77395242f9b3cb6ef003c5ed74f9b5be78404450
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/blocktrron/poemgr.git
PKG_MIRROR_HASH:=68034f886af8a4ebfd869af940510f755d660362a6069ac49c1ae6ce16cbd950

PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/poemgr
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libuci +libjson-c
  TITLE:=Utility to control PoE ports on the UniFi Flex switch
endef

define Package/poemgr/conffiles
/etc/config/usteer
endef

define Package/poemgr/install
	$(INSTALL_DIR) $(1)/sbin $(1)/usr/lib/poemgr/config $(1)/etc/config $(1)/etc/uci-defaults $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/poemgr $(1)/sbin/poemgr
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/contrib/uswlite-pse-enable $(1)/usr/lib/poemgr/uswlite-pse-enable
	$(CP) $(PKG_BUILD_DIR)/contrib/usw-lite.config $(1)/usr/lib/poemgr/config/usw-lite.config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/contrib/uci-defaults.sh $(1)/etc/uci-defaults/99-poemgr
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/contrib/procd-init.sh $(1)/etc/init.d/poemgr
endef


$(eval $(call BuildPackage,poemgr))
