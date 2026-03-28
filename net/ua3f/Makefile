include $(TOPDIR)/rules.mk

PKG_NAME:=ua3f
PKG_VERSION:=2.7.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/SunBK201/UA3F/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=cad3de3427590c48787029a04d4a49e43fadcf9a3130cc601be4cd31c0cec7f3

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=SunBK201 <sunbk201gm@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/sunbk201/ua3f
GO_PKG_LDFLAGS_X:=main.appVersion=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/ua3f
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=Advanced HTTP Rewriting Tool
	URL:=https://github.com/SunBK201/UA3F
	DEPENDS:=$(GO_ARCH_DEPENDS) +ipset +iptables +iptables-mod-tproxy +iptables-mod-extra +iptables-mod-ipopt +iptables-mod-nfqueue +iptables-mod-conntrack-extra +kmod-nf-conntrack-netlink
endef

define Package/ua3f/description
	Advanced HTTP Rewriting Tool
endef

define Build/Prepare
	$(CP) ../src/* $(PKG_BUILD_DIR)
endef

define Package/ua3f/conffiles
/etc/config/ua3f
endef

define Package/ua3f/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/ua3f $(1)/usr/bin/ua3f

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/ua3f.conf $(1)/etc/config/ua3f

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ua3f.init $(1)/etc/init.d/ua3f

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/uci-defaults $(1)/etc/uci-defaults/luci-ua3f
endef

define Package/ua3f/postrm
#!/bin/sh
uci -q set ua3f.enabled.enabled=0
uci -q commit ua3f
[ -f "/etc/config/ucitrack" ] && {
	uci -q delete ucitrack.ua3f
	uci -q commit ucitrack
}
endef

$(eval $(call GoBinPackage,ua3f))
$(eval $(call BuildPackage,ua3f))
