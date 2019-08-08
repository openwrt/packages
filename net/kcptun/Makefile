include $(TOPDIR)/rules.mk

PKG_NAME:=kcptun
PKG_VERSION:=20190725
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/xtaci/kcptun/tar.gz/v${PKG_VERSION}?
PKG_HASH:=65c0d0d4f7e3bb3c3b91e23ff2eb6621455d6d376a4f17e6fb2017337ce711c1

PKG_MAINTAINER:=Dengfeng Liu <liudf0716@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/xtaci/kcptun

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/kcptun/template
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=KCP-based Secure Tunnel 
  URL:=https://github.com/xtaci/kcptun
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/kcptun-c
  $(call Package/kcptun/template)
  TITLE+= (client)
endef

define Package/kcptun-s
  $(call Package/kcptun/template)
  TITLE+= (server)
endef

define Package/kcptun/description
  kcptun is a Stable & Secure Tunnel Based On KCP with N:M Multiplexing
endef
Package/kcptun-c/description = $(Package/kcptun/description)
Package/kcptun-s/description = $(Package/kcptun/description)

GO_PKG_LDFLAGS_X:=main.VERSION=$(PKG_VERSION)
GO_PKG_LDFLAGS:=-s -w

define Package/kcptun/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(2) $(1)/usr/bin/$(3)
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/$(3).conf $(1)/etc/config/$(3)
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/$(3).init $(1)/etc/init.d/$(3)
endef

define Package/kcptun-c/install
  $(call Package/kcptun/install,$(1),client,kcptun-c)
endef

define Package/kcptun-s/install
  $(call Package/kcptun/install,$(1),server,kcptun-s)
endef

$(eval $(call GoBinPackage,kcptun-c))
$(eval $(call BuildPackage,kcptun-c))
$(eval $(call GoBinPackage,kcptun-s))
$(eval $(call BuildPackage,kcptun-s))
