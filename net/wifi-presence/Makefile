include $(TOPDIR)/rules.mk

PKG_NAME:=wifi-presence
PKG_VERSION:=0.3.0
PKG_RELEASE:=2

PKG_SOURCE:=-$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/awilliams/wifi-presence/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=70014a3d72635fece3ec666bcf0235f7bbd028cea6bc10d8548fbb2a8a8cbc1d

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Adam Williams <pwnfactory@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

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
