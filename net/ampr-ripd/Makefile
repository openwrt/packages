include $(TOPDIR)/rules.mk

PKG_NAME:=ampr-ripd
PKG_VERSION:=2.4.2
PKG_RELEASE:=2

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
  Routing daemon written in C similar to Hessu's rip44d including
  optional resending of RIPv2 broadcasts for router injection.
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
uci show firewall | grep "@rule" \
   | awk -F= '/name='\''(Net 44 ICMP Echo Request|Net 44 Router ICMP|ipip)'\''/ {split($$1, conf, /\./); print conf[2]}' \
   | sort -r \
   | while read i; do
      uci del firewall.$$i
   done
uci commit firewall

echo "Removing network rules..."
uci show network \
   | awk -F= '/lookup='\''44'\''/ {split($$1, conf, /\./); print conf[2]}' \
   | sort -r \
   | while read i; do
      uci del network.$$i
   done
uci commit network

echo "Removing firewall zone forwarding rules..."
uci show firewall | grep "@forwarding" \
   | awk -F= '/src='\''(amprwan|amprlan)'\''/ {split($$1, conf, /\./); print conf[2]}' \
   | sort -r \
   | while read i; do
      uci del firewall.$$i
   done
uci commit firewall

echo "Removing firewall zones..."
uci show firewall | grep "@zone" \
   | awk -F= '/name='\''(amprwan|amprlan)'\''/ {split($$1, conf, /\./); print conf[2]}' \
   | sort -r \
   | while read i; do
      uci del firewall.$$i
   done
uci commit firewall

echo "Removing network interfaces..."
uci del network.amprwan
uci del network.amprlan
uci commit network

endef

$(eval $(call BuildPackage,ampr-ripd))
