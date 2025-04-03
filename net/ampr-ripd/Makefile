include $(TOPDIR)/rules.mk

PKG_NAME:=ampr-ripd
PKG_VERSION:=2.4
PKG_RELEASE:=1
PKG_SOURCE_URL:=https://www.yo2loj.ro/hamprojects
PKG_HASH:=18d00c898d22a5ee1fb2c153a49358100b5ff22b2b57668472a651998fb0bf6f
PKG_MAINTAINER:=Dan Srebnick <k2ie@k2ie.net>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/ampr-ripd
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Routing and Redirection
	DEPENDS:=+kmod-ipip +ip-full
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
endef

define Package/ampr-ripd/postrm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
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

fi
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
