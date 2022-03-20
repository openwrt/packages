include $(TOPDIR)/rules.mk

PKG_NAME:=wifi-presence
PKG_VERSION:=0.1.2
PKG_RELEASE:=1

PKG_SOURCE:=-$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/awilliams/wifi-presence/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=f5cf8bf36e3c17ad4b0486007532030760c22c5f63bd63707d911ab94bd744df

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Adam Williams <pwnfactory@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/awilliams/wifi-presence
GO_PKG_BUILD_PKG:=$(GO_PKG)/cmd/wifi-presence

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/wifi-presence
  SECTION:=net
  CATEGORY:=Network
  TITLE:=WiFi presence detection with Home Assistant integration
  URL:=https://github.com/awilliams/wifi-presence
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/wifi-presence/description
  WiFi presence detection with Home Assistant integration.
  Publish WiFi client connect and disconnect events to MQTT.
endef

define Package/wifi-presence/conffiles
/etc/config/wifi-presence
endef

define Package/wifi-presence/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/wifi-presence $(1)/usr/bin

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/wifi-presence.conf $(1)/etc/config/wifi-presence

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/wifi-presence.init $(1)/etc/init.d/wifi-presence
endef

$(eval $(call GoBinPackage,wifi-presence))
$(eval $(call BuildPackage,wifi-presence))
