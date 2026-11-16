include $(TOPDIR)/rules.mk

PKG_NAME:=tmhi
PKG_VERSION:=0.5.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/dave-atx/g4arctrl/releases/download/v$(PKG_VERSION)
PKG_HASH:=a4073fe8520dbefb778fbb07b03435697c30d813ef1185e9c22463e02c5819bc

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Dave Marquard <dave@marquard.org>

include $(INCLUDE_DIR)/package.mk

define Package/tmhi
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Status, history and stuck-band detection for T-Mobile Home Internet
  URL:=https://github.com/dave-atx/g4arctrl
  PKGARCH:=all
  DEPENDS:=+curl +jq
endef

define Package/tmhi/description
  Shows band, channel width and signal quality from a T-Mobile Home Internet
  gateway (Arcadyan KVD21 / TMO-G4AR, Sagemcom Fast 5688W, Sercomm TMO-G4SE)
  on the router's WAN side, logs them once a minute, and tells you when the
  gateway has been stuck on the wrong band long enough to need a reboot.
endef

define Package/tmhi/conffiles
/etc/config/tmhi
/etc/hotplug.d/tmhi/
/etc/tmhi/
endef

define Build/Compile
endef

define Package/tmhi/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d $(1)/etc/config $(1)/etc/hotplug.d/tmhi
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tmhi $(1)/usr/bin/tmhi
	$(INSTALL_BIN) ./files/tmhi.init $(1)/etc/init.d/tmhi
	$(INSTALL_CONF) ./files/tmhi.config $(1)/etc/config/tmhi
	$(INSTALL_DATA) ./files/tmhi.hotplug $(1)/etc/hotplug.d/tmhi/50-example
endef

$(eval $(call BuildPackage,tmhi))
