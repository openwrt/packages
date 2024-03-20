include $(TOPDIR)/rules.mk

PKG_NAME:=wgsd
PKG_VERSION:=0.3.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jwhited/wgsd/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b64e7c93a98e444e6ef46871fb73349c485c501469758e459e10188d7abfec28

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Vladimir Ermakov <vooon341@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/jwhited/wgsd
GO_PKG_EXCLUDES:=test

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/wgsd/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=WireGuard Service Discovery
  URL:=https://github.com/jwhited/wgsd
  DEPENDS:=+kmod-wireguard
endef

define Package/wgsd-coredns
  $(call Package/wgsd/Default)
  TITLE+= DNS-SD server
endef

define Package/wgsd-client
  $(call Package/wgsd/Default)
  TITLE+= Client
endef

define Package/wgsd/Default/description
  wgsd is a CoreDNS plugin that serves WireGuard peer information via DNS-SD (RFC6763) semantics.
  This enables use cases such as:

  - Building a mesh of WireGuard peers from a central registry
  - Dynamic discovery of WireGuard Endpoint addressing (both IP address and port number)
  - NAT-to-NAT WireGuard connectivity where UDP hole punching is supported.
endef

define Package/wgsd-coredns/description
  $(call Package/wgsd/Default/description)

  CoreDNS binary.
endef

define Package/wgsd-client/description
  $(call Package/wgsd/Default/description)

  Client binary.
endef

define Package/wgsd-coredns/conffiles
/etc/Corefile
endef

define Package/wgsd-coredns/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/coredns $(1)/usr/bin/wgsd-coredns

	$(INSTALL_DIR) $(1)/etc/
	$(INSTALL_CONF) $(CURDIR)/files/Corefile $(1)/etc/Corefile
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/wgsd-coredns.init $(1)/etc/init.d/wgsd-coredns
endef

define Package/wgsd-client/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/wgsd-client $(1)/usr/bin/wgsd-client
endef

$(eval $(call BuildPackage,wgsd-coredns))
$(eval $(call BuildPackage,wgsd-client))
