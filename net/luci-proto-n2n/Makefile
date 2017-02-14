include $(TOPDIR)/rules.mk

PKG_NAME:=luci-proto-n2n
PKG_VERSION:=1.0
PKG_RELEASE:=7
PKG_MAINTAINER:=Marek Sedlak <bodka.zavinac@gmail.com>
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/luci-proto-n2n
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=5. Protocols
  TITLE:=Support for N2N VPN
  DEPENDS:=+n2n-edge
  PKGARCH:=all
endef

define Package/luci-proto-n2n/description
Support for N2N VPN
endef

define Package/luci-proto-n2n/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/admin_network
	$(INSTALL_DATA) ./files/cbi/proto_n2n.lua $(1)/usr/lib/lua/luci/model/cbi/admin_network
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/network
	$(INSTALL_DATA) ./files/network/proto_n2n.lua $(1)/usr/lib/lua/luci/model/network
endef

define Build/Compile
endef

$(eval $(call BuildPackage,luci-proto-n2n))
