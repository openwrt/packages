include $(TOPDIR)/rules.mk

PKG_NAME:=dhtd
PKG_VERSION:=0.2.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/mwarning/dhtd/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=0e239c969400537fda549b74f0555bddc2f1fe4ab3c00abe539970dfefab6599

PKG_MAINTAINER:=Moritz Warning <moritzwarning@web.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/dhtd
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=DHT Daemon
  URL:=https://github.com/mwarning/dhtd
endef

define Package/dhtd/description
  Standalone BitTorrent DHT daemon. Lookup and announce
  hash identifiers via command line interface.
endef

MAKE_FLAGS += FEATURES="cli lpd"

define Package/dhtd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/dhtd $(1)/usr/bin/
	$(LN) /usr/bin/dhtd $(1)/usr/bin/dhtd-ctl
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/dhtd.init $(1)/etc/init.d/dhtd
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/dhtd.config $(1)/etc/config/dhtd
endef

$(eval $(call BuildPackage,dhtd))
