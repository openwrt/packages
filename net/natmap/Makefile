include $(TOPDIR)/rules.mk

PKG_NAME:=natmap
PKG_VERSION:=20250721
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/heiher/natmap/releases/download/$(PKG_VERSION)
PKG_HASH:=25d3288c1654191b7884d6c83b8f669ce788fbab95ebe26d84b65c63ceaa3094

PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>, Ray Wang <git@hev.cc>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=License

PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/natmap
  SECTION:=net
  CATEGORY:=Network
  TITLE:=TCP/UDP port mapping tool for full cone NAT
  URL:=https://github.com/heiher/natmap
endef

MAKE_FLAGS += REV_ID="$(PKG_VERSION)"

define Package/natmap/conffiles
/etc/config/natmap
endef

define Package/natmap/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/natmap $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/natmap/
	$(INSTALL_BIN) ./files/natmap-update.sh $(1)/usr/lib/natmap/update.sh
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/natmap.config $(1)/etc/config/natmap
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/natmap.init $(1)/etc/init.d/natmap
endef

$(eval $(call BuildPackage,natmap))
