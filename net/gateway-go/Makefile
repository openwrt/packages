include $(TOPDIR)/rules.mk

PKG_NAME:=gateway-go
PKG_VERSION:=0.1.92
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/OpenIoTHub/gateway-go/tar.gz/v${PKG_VERSION}?
PKG_HASH:=dd8074d9312e00ff957ffd1f3be7ba118a9b8cc31f07aa1ed594ef07931dab16

PKG_MAINTAINER:=Yu Fang <newfarry@126.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/gateway-go-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

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

$(eval $(call GoBinPackage,gateway-go))
$(eval $(call BuildPackage,gateway-go))
