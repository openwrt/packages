include $(TOPDIR)/rules.mk

PKG_NAME:=gateway-go
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/OpenIoTHub/gateway-go/tar.gz/v${PKG_VERSION}?
PKG_HASH:=7d04d923ae39c2c9ffb4c5de2a3f335798ff167992a6d89d9538d0bf3867b6f8

PKG_MAINTAINER:=Yu Fang <newfarry@126.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/gateway-go-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/OpenIoTHub/gateway-go

GO_PKG_LDFLAGS_X:=\
	main.version=v$(PKG_VERSION) \
	main.commit=$(PKG_VERSION)  \
	main.builtBy=openwrt \

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/gateway-go
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=gateway-go - gateway of OpenIoTHub
  URL:=https://github.com/OpenIoTHub/gateway-go
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/gateway-go/description
  gateway-go is GateWay Client for OpenIoTHub.
endef

define Package/gateway-go/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gateway-go $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/gateway-go/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/gateway-go.yaml $(1)/etc/gateway-go/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/gateway-go.init $(1)/etc/init.d/gateway-go
endef

define Package/gateway-go/conffiles
/etc/gateway-go/gateway-go.yaml
endef

$(eval $(call GoBinPackage,gateway-go))
$(eval $(call BuildPackage,gateway-go))
