include $(TOPDIR)/rules.mk

PKG_NAME:=ampr-ripd
PKG_VERSION:=2.4
PKG_RELEASE:=1
PKG_SOURCE_URL:=http://www.yo2loj.ro/hamprojects
PKG_MD5SUM:=5429401ab6f8f793448bef11029d7ead

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)    
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Routing and Redirection
	DEPENDS:=+kmod-ipip +ip-full
	TITLE:=Routing daemon for the AMPR network
	URL:=http://www.yo2loj.ro/hamprojects
	MAINTAINER:=Dan Srebnick <k2ie@k2ie.net>
endef

define Package/$(PKG_NAME)/description
	Routing daemon written in C similar to Hessu's rip44d including optional resending of RIPv2 broadcasts for router injection.
endef

CONFIGURE_VARS+= \
	CC="$(TOOLCHAIN_DIR)/bin/$(TARGET_CC)"
	COPT="$(TARGET_COPT)"

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/$(PKG_NAME)-init $(1)/etc/init.d/$(PKG_NAME)
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
   echo "Installing with values:

  amprhost=$$amprhost
  amprmask=$$amprmask
  amprnet=$$amprnet
"
   echo "Creating /etc/ampr-ripd.conf..."
   echo "# Set to your AMPR allocation
# eg. 44.128.0.32/255.255.255.240
TUNNET=$$amprnet/$$amprmask" > /etc/ampr-ripd.conf
   
   echo "Installing routing rules..."
   r=`uci add network rule`
   uci set network.$$r.dest='44.0.0.0/9'
   uci set network.$$r.lookup='44'
   uci set network.$$r.priority='44'
   r=`uci add network rule`
   uci set network.$$r.dest='44.128.0.0/10'
   uci set network.$$r.lookup='44'
   uci set network.$$r.priority='44'
   r=`uci add network rule`
   uci set network.$$r.source=$$amprnet
   uci set network.$$r.lookup='44'
   uci set network.$$r.priority='45'

   echo "Installing network interfaces..."
   uci set network.amprlan=interface
   uci set network.amprlan.proto='static'
   uci set network.amprlan.device='br-lan'
   uci set network.amprlan.force_link='0'
   uci set network.amprlan.ipaddr=$$amprhost
   uci set network.amprlan.netmask=$$amprmask
   uci set network.amprlan.defaultroute='0'
   uci set network.amprlan.ip4table='44'
   uci set network.amprlan.delegate='0'
   uci set network.amprwan=interface
   uci set network.amprwan.device='tunl0'
   uci set network.amprwan.proto='static'
   uci set network.amprwan.ipaddr=$$amprhost
   uci set network.amprwan.netmask=$$amprmask
   uci commit network

   echo "Installing firewall zones..."
   z=`uci add firewall zone`
   uci set firewall.$$z.name='amprlan'
   uci set firewall.$$z.network='amprlan'
   z=`uci add firewall zone`
   uci set firewall.$$z.name='amprwan'
   uci set firewall.$$z.network='amprwan'
   z=`uci add firewall forwarding`
   uci set firewall.$$z.src='amprlan'
   uci set firewall.$$z.dest='amprwan'
   uci commit firewall

   echo "Installing firewall rules..."
   f=`uci add firewall rule`
   uci set firewall.$$f.name='ipip'
   uci set firewall.$$f.proto='ipencap'
   uci set firewall.$$f.src='wan'
   uci set firewall.$$f.target='ACCEPT'
   uci set firewall.$$f.family='ipv4'
   uci set firewall.$$f.icmp_type='echo-request'
   f=`uci add firewall rule`
   uci set firewall.$$f.name='Net 44 ICMP Echo Request'
   uci set firewall.$$f.proto='icmp'
   uci set firewall.$$f.src='amprwan'
   uci set firewall.$$f.dest='amprlan'
   uci set firewall.$$f.target='ACCEPT'
   uci set firewall.$$f.family='ipv4'
   uci set firewall.$$f.icmp_type='echo-request'
   f=`uci add firewall rule`
   uci set firewall.$$f.name='Net 44 Router ICMP'
   uci set firewall.$$f.proto='icmp'
   uci set firewall.$$f.src='amprwan'
   uci set firewall.$$f.target='ACCEPT'
   uci set firewall.$$f.family='ipv4'
   uci set firewall.$$f.icmp_type='echo-request'
   uci commit firewall
fi
endef

define Package/$(PKG_NAME)/postrm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
   echo "Removing firewall rules..."
   for i in `seq 99 -1 0`; do
      if [ `uci -q get firewall.@rule[$$i]` ]; then
         name=`uci get firewall.@rule[$$i].name`
         if [ "$$name" = "Net 44 ICMP Echo Request" ] \
            || [ "$$name" = "Net 44 Router ICMP" ]    \
            || [ "$$name" = "ipip" ]; then
            uci del firewall.@rule[$$i]
         fi
      fi
   done
   uci commit firewall

   echo "Removing network rules..."
   for i in `seq 99 -1 0`; do
      if [ `uci -q get network.@rule[$$i]` ]; then
         lookup=`uci get network.@rule[$$i].lookup`
         if [ "$$lookup" = "44" ]; then
            uci del network.@rule[$$i]
         fi
      fi
   done
   uci commit network

   echo "Removing firewall zone forwarding rules..."
   for i in `seq 99 -1 0`; do
      if [ `uci -q get firewall.@forwarding[$$i]` ]; then
         name=`uci get firewall.@forwarding[$$i].src`
         if [ "$$name" = "amprlan" ] || [ "$$name" = "amprwan" ]; then
            uci del firewall.@forwarding[$$i]
         fi
      fi
   done

   echo "Removing firewall zones..."
   for i in `seq 99 -1 0`; do
      if [ `uci -q get firewall.@zone[$$i]` ]; then
         name=`uci get firewall.@zone[$$i].name`
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
