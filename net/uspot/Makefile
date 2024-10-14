include $(TOPDIR)/rules.mk

PKG_NAME:=uspot
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Thibaut VARÈNE <hacks@slashdirt.org>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/f00b4r0/uspot.git
PKG_SOURCE_DATE:=2024-05-03
PKG_SOURCE_VERSION:=92d3356d3fb3ae36199dbd494b5d9a9ae1a9db07
PKG_MIRROR_HASH:=ae6bb9245945cf207d91b1aa36fb0db2b03333343714c1cacd046dd2c7ee3c79

CMAKE_SOURCE_SUBDIR:=src

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/uspot
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
  TITLE:=uspot hotspot daemon
  EXTRA_DEPENDS:=ucode (>= 2023-11-07)
  DEPENDS:=+conntrack \
	   +libblobmsg-json +liblucihttp-ucode +libradcli +libubox +libubus +libuci \
	   +uspotfilter \
	   +ucode +ucode-mod-log +ucode-mod-math +ucode-mod-nl80211 +ucode-mod-rtnl +uhttpd-mod-ucode +ucode-mod-uloop

endef

define Package/uspot/description
  This package implements a captive portal supporting click-to-continue,
  simple credential-based as well as RADIUS authentication.
  It is UAM capable, and has limited support for RFC5176
  RADIUS Dynamic Authorization Extensions.
  It is meant to be a drop-in replacement for CoovaChilli,
  leveraging the performance and flexibility of the nftables firewall
  without the need for extra kernel modules.
endef

define Package/uspot/conffiles
/etc/config/uspot
endef

define Package/uspot-www
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
  TITLE:=uspot default user interface files
  DEPENDS:=+uspot
  PKGARCH:=all
endef

define Package/uspot-www/description
  This package provides CSS and HTML templates for uspot UI.
  This package must be installed with uspot unless a local alternative is provided.
endef

define Package/uspotfilter
  SECTION:=net
  CATEGORY:=Network
  TITLE:=uspot firewall interface
  EXTRA_DEPENDS:=ucode (>= 2023-11-07)
  DEPENDS:=+conntrack +nftables-json +ucode +ucode-mod-rtnl +ucode-mod-uloop
  PKGARCH:=all
endef

define Package/uspotfilter/description
  This package provides the nftables firewall interface to uspot.
  It is compatible with firewall4.
endef

define Package/uspot/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/share $(1)/usr/lib/ucode $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/radius-client $(1)/usr/bin/radius-client
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uspot-das $(1)/usr/bin/uspot-das
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/libuam.so $(1)/usr/lib/ucode/uam.so
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/files/etc/config/uspot $(1)/etc/config/uspot
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/init.d/uspot $(1)/etc/init.d/uspot
	$(CP) $(PKG_BUILD_DIR)/files/usr/bin $(1)/usr/
	$(CP) $(PKG_BUILD_DIR)/files/usr/share/uspot $(1)/usr/share/
endef

define Package/uspot-www/install
	$(CP) $(PKG_BUILD_DIR)/files/www-uspot $(1)/
endef

define Package/uspotfilter/install
	$(INSTALL_DIR) $(1)/usr/share $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/init.d/uspotfilter $(1)/etc/init.d/uspotfilter
	$(CP) $(PKG_BUILD_DIR)/files/usr/share/uspotfilter $(1)/usr/share/
endef

$(eval $(call BuildPackage,uspot))
$(eval $(call BuildPackage,uspot-www))
$(eval $(call BuildPackage,uspotfilter))
