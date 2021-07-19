#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=miniupnpd
PKG_VERSION:=2.2.2
PKG_RELEASE:=3

PKG_SOURCE_URL:=https://miniupnp.tuxfamily.org/files
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=4b01c403d01c6ab140c9e4e744c89cdb66cbe25145d7a0d4566cc3fdcc0240c3

PKG_MAINTAINER:=
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:miniupnp_project:miniupnpd

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/version.mk

define Package/miniupnpd/Default
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:= \
	+IPV6:ip6tables \
	+IPV6:libip6tc \
	+iptables \
	+libcap-ng \
	+libip4tc \
	+libmnl \
	+libnetfilter-conntrack \
	+libuuid
  TITLE:=Lightweight UPnP IGD, NAT-PMP & PCP daemon
  SUBMENU:=Firewall
  URL:=https://miniupnp.tuxfamily.org/
endef

define Package/miniupnpd
  $(call Package/miniupnpd/Default)
  TITLE+= (IGDv2)
  CONFLICTS:=miniupnpd-igdv1
  VARIANT:=igdv2
endef

define Package/miniupnpd-igdv1
  $(call Package/miniupnpd/Default)
  TITLE+= (IGDv1)
  PROVIDES:=miniupnpd
  VARIANT:=igdv1
endef

define Package/miniupnpd/conffiles
/etc/config/upnpd
endef

Package/miniupnpd-igdv1/conffiles = $(Package/miniupnpd/conffiles)

define Build/Prepare
	$(call Build/Prepare/Default)
	echo "$(VERSION_NUMBER)" | tr '() ' '_' >$(PKG_BUILD_DIR)/os.openwrt
endef

CONFIGURE_ARGS = \
	$(if $(CONFIG_IPV6),--ipv6) \
	--leasefile \
	--portinuse \
	--firewall=iptables \
	--disable-fork

ifeq ($(BUILD_VARIANT),igdv2)
	CONFIGURE_ARGS += --igd2
endif

TARGET_CFLAGS += $(FPIC) -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

define Package/miniupnpd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/usr/share/miniupnpd

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/miniupnpd $(1)/usr/sbin/miniupnpd
	$(INSTALL_BIN) ./files/miniupnpd.init $(1)/etc/init.d/miniupnpd
	$(INSTALL_CONF) ./files/upnpd.config $(1)/etc/config/upnpd
	$(INSTALL_DATA) ./files/miniupnpd.hotplug $(1)/etc/hotplug.d/iface/50-miniupnpd
	$(INSTALL_BIN) ./files/miniupnpd.defaults $(1)/etc/uci-defaults/99-miniupnpd
	$(INSTALL_DATA) ./files/firewall.include $(1)/usr/share/miniupnpd/firewall.include
endef

Package/miniupnpd-igdv1/install = $(Package/miniupnpd/install)

$(eval $(call BuildPackage,miniupnpd))
$(eval $(call BuildPackage,miniupnpd-igdv1))
