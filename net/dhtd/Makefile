include $(TOPDIR)/rules.mk

PKG_NAME:=dhtd
PKG_VERSION:=1.0.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/mwarning/dhtd/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=67024a7fbd8aef0c99635b1a1f02cc835f6f4c08b6aeb97d2db55caeb3716c6f

PKG_MAINTAINER:=Moritz Warning <moritzwarning@web.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/dhtd
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=BitTorrent
  TITLE:=BitTorrent DHT Server
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
