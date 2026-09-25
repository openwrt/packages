include $(TOPDIR)/rules.mk

PKG_NAME:=uneighbord
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0-only
PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>

include $(INCLUDE_DIR)/package.mk

define Package/uneighbord
  SECTION:=net
  CATEGORY:=Network
  TITLE:=802.11k Neighbor Report synchronizer
  DEPENDS:=+ucode +ucode-mod-ubus +ucode-mod-uloop +ucode-mod-socket +ucode-mod-uci +ucode-mod-log
  PKGARCH:=all
endef

define Package/uneighbord/description
  Synchronize hostapd 802.11k Neighbor Reports between local BSSes and
  OpenWrt access points on the same LAN.
endef

define Build/Compile
endef

define Package/uneighbord/conffiles
/etc/config/uneighbord
endef

define Package/uneighbord/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d $(1)/usr/sbin
	$(INSTALL_CONF) ./files/etc/config/uneighbord $(1)/etc/config/uneighbord
	$(INSTALL_BIN) ./files/etc/init.d/uneighbord $(1)/etc/init.d/uneighbord
	$(INSTALL_BIN) ./files/usr/sbin/uneighbord $(1)/usr/sbin/uneighbord
endef

$(eval $(call BuildPackage,uneighbord))
