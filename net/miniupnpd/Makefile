#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=miniupnpd
PKG_VERSION:=2.0.20180503
PKG_RELEASE:=2

PKG_SOURCE_URL:=http://miniupnp.free.fr/files
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=b61bed16865f8692803a9f155523ca7c6e01c65db20362b6173226b08ce12a0c

PKG_MAINTAINER:=Kevin Darbyshire-Bryant <ldir@darbyshire-bryant.me.uk>
PKG_LICENSE:=BSD-3-Clause

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/version.mk

define Package/miniupnpd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+iptables +libip4tc +IPV6:libip6tc +IPV6:ip6tables +libuuid
  TITLE:=Lightweight UPnP IGD, NAT-PMP & PCP daemon
  SUBMENU:=Firewall
  URL:=http://miniupnp.free.fr/
endef

define Package/miniupnpd/conffiles
/etc/config/upnpd
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	echo "$(VERSION_NUMBER)" | tr '() ' '_' >$(PKG_BUILD_DIR)/os.openwrt
endef

TARGET_CFLAGS += -flto -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -flto -Wl,--gc-sections
MAKE_FLAGS += \
	TARGET_OPENWRT=1 TEST=0 LIBS="" \
	CC="$(TARGET_CC) -DIPTABLES_143 -lip4tc -luuid \
		$(if $(CONFIG_IPV6),-lip6tc)" \
	CONFIG_OPTIONS="--portinuse --leasefile --igd2 \
		$(if $(CONFIG_IPV6),--ipv6)" \
	-f Makefile.linux miniupnpd

define Package/miniupnpd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/usr/share/miniupnpd

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/miniupnpd $(1)/usr/sbin/miniupnpd
	$(INSTALL_BIN) ./files/miniupnpd.init $(1)/etc/init.d/miniupnpd
	$(INSTALL_CONF) ./files/upnpd.config $(1)/etc/config/upnpd
	$(INSTALL_DATA) ./files/miniupnpd.hotplug $(1)/etc/hotplug.d/iface/50-miniupnpd
	$(INSTALL_BIN) ./files/miniupnpd.defaults $(1)/etc/uci-defaults/99-miniupnpd
	$(INSTALL_DATA) ./files/firewall.include $(1)/usr/share/miniupnpd/firewall.include
endef

$(eval $(call BuildPackage,miniupnpd))
