include $(TOPDIR)/rules.mk

PKG_NAME:=frp
PKG_VERSION:=0.34.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/fatedier/frp/tar.gz/v${PKG_VERSION}?
PKG_HASH:=f03e280d9e8fdd4948ed6a5d141e927bf9b5168d7a47a4f3e90a08065e5f192d

PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/fatedier/frp
GO_PKG_BUILD_PKG:=github.com/fatedier/frp/cmd/...

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/frp/template
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=frp - fast reverse proxy
  URL:=https://github.com/fatedier/frp
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/frpc
  $(call Package/frp/template)
  TITLE+= (client)
endef

define Package/frps
  $(call Package/frp/template)
  TITLE+= (server)
endef

define Package/frp/description
  frp is a fast reverse proxy to help you expose a local server behind
  a NAT or firewall to the internet.
endef
Package/frpc/description = $(Package/frp/description)
Package/frps/description = $(Package/frp/description)

define Package/frp/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(2) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/frp/$(2).d/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/conf/$(2)_full.ini $(1)/etc/frp/$(2).d/
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/$(2).config $(1)/etc/config/$(2)
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/$(2).init $(1)/etc/init.d/$(2)
endef

define Package/frpc/conffiles
/etc/config/frpc
endef

define Package/frps/conffiles
/etc/config/frps
endef

define Package/frpc/install
  $(call Package/frp/install,$(1),frpc)
endef

define Package/frps/install
  $(call Package/frp/install,$(1),frps)
endef

$(eval $(call GoBinPackage,frpc))
$(eval $(call BuildPackage,frpc))
$(eval $(call GoBinPackage,frps))
$(eval $(call BuildPackage,frps))
