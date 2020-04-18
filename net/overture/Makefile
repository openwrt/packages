include $(TOPDIR)/rules.mk

PKG_NAME:=overture
PKG_VERSION:=1.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/shawn1m/overture/tar.gz/v${PKG_VERSION}?
PKG_HASH:=a7a568cc65f2a1714f036c555b95d3be27234b98ae951cb748198fecce1bb1e4

PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/shawn1m/overture
GO_PKG_BUILD_PKG:=$(GO_PKG)/main

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/overture
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=A customized DNS forwarder written in Go
  URL:=https://github.com/shawn1m/overture
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/overture/description
  Overture is a DNS server/forwarder/dispatcher written in Go.
endef

define Package/overture/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/main $(1)/usr/bin/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/$(PKG_NAME)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/config.sample.json $(1)/etc/$(PKG_NAME)/config.json
	$(INSTALL_DATA) ./files/*_sample $(1)/etc/$(PKG_NAME)/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
endef

$(eval $(call GoBinPackage,overture))
$(eval $(call BuildPackage,overture))
