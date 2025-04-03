include $(TOPDIR)/rules.mk

PKG_NAME:=ampr-ripd
PKG_VERSION:=2.4.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=https://yo2loj.ro/hamprojects
PKG_HASH:=e4635bd0f88c1f2b0777e948a00d0470aa97254ec4b0b8fd75c79d109995a350

PKG_MAINTAINER:=Dan Srebnick <k2ie@k2ie.net>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/ampr-ripd
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  DEPENDS:=+kmod-ipip +ip
  TITLE:=Routing daemon for the AMPR network
  URL:=https://www.yo2loj.ro/hamprojects
endef

define Package/ampr-ripd/description
  Routing daemon written in C similar to Hessu's rip44d including optional resending of RIPv2 broadcasts for router injection.
endef

CONFIGURE_VARS+= \
	CC="$(TOOLCHAIN_DIR)/bin/$(TARGET_CC)"
	COPT="$(TARGET_COPT)"

define Package/ampr-ripd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ampr-ripd $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ampr-ripd-init $(1)/etc/init.d/ampr-ripd
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/99-ampr-ripd $(1)/etc/uci-defaults/99-ampr-ripd
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/ampr-ripd-config $(1)/etc/config/ampr-ripd
endef

define Package/ampr-ripd/postrm
#!/bin/sh
[ "$${PKG_UPGRADE}" = 1 ] && exit 0
[ -z "$${IPKG_INSTROOT}" ] || exit 0

echo "Removing firewall rules..."
for i in $$(seq 99 -1 0); do
   if [ $$(uci -q get firewall.@rule[$$i]) ]; then
      name=$$(uci get firewall.@rule[$$i].name)
      if [ "$$name" = "Net 44 ICMP Echo Request" ] \
         || [ "$$name" = "Net 44 Router ICMP" ]    \
         || [ "$$name" = "ipip" ]; then
         uci del firewall.@rule[$$i]
      fi
   fi
done
uci commit firewall

echo "Removing network rules..."
for i in $$(seq 99 -1 0); do
   if [ $$(uci -q get network.@rule[$$i]) ]; then
      lookup=$$(uci get network.@rule[$$i].lookup)
      if [ "$$lookup" = "44" ]; then
         uci del network.@rule[$$i]
      fi
   fi
done
uci commit network

echo "Removing firewall zone forwarding rules..."
for i in $$(seq 99 -1 0); do
   if [ $$(uci -q get firewall.@forwarding[$$i]) ]; then
      name=$$(uci get firewall.@forwarding[$$i].src)
      if [ "$$name" = "amprlan" ] || [ "$$name" = "amprwan" ]; then
         uci del firewall.@forwarding[$$i]
      fi
   fi
done

echo "Removing firewall zones..."
for i in $$(seq 99 -1 0); do
   if [ $$(uci -q get firewall.@zone[$$i]) ]; then
      name=$$(uci get firewall.@zone[$$i].name)
      if [ "$$name" = "amprlan" ] || [ "$$name" = "amprwan" ]; then
         uci del firewall.@zone[$$i]
      fi
   fi
done
uci commit firewall

echo "Removing network interfaces..."
uci del network.amprwan
uci del network.amprlan
uci commit network

endef

$(eval $(call BuildPackage,ampr-ripd))
