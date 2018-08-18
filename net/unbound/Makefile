#
# Copyright (C) 2010-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=unbound
PKG_VERSION:=1.6.8
PKG_RELEASE:=3

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Eric Luehrsen <ericluehrsen@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.unbound.net/downloads
PKG_HASH:=e3b428e33f56a45417107448418865fe08d58e0e7fea199b855515f60884dd49

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/unbound/Default
  TITLE:=Validating Recursive DNS Server
  URL:=http://www.unbound.net/
  DEPENDS:=+libopenssl
endef

define Package/unbound
  $(call Package/unbound/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  USERID:=unbound=553:unbound=553
  TITLE+= (daemon)
  DEPENDS+= +libunbound
endef

define Package/unbound/description
  This package contains the Unbound daemon.
endef

define Package/unbound-anchor
  $(call Package/unbound/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE+= (DSKEY utility)
  DEPENDS+= +unbound +libexpat
endef

define Package/unbound-anchor/description
  This package contains the Unbound anchor utility.
endef

define Package/unbound-control
  $(call Package/unbound/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE+= (control utility)
  DEPENDS+= +unbound
endef

define Package/unbound-control/description
  This package contains the Unbound control utility.
endef

define Package/unbound-control-setup
  $(call Package/unbound/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE+= (control setup)
  DEPENDS+= +unbound-control +openssl-util
endef

define Package/unbound-control-setup/description
  This package contains the Unbound control setup utility.
endef

define Package/unbound-host
  $(call Package/unbound/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE+= (lookup utility)
  DEPENDS+= +libunbound
endef

define Package/unbound-host/description
  This package contains the Unbound DNS lookup utility.
endef

define Package/libunbound
  $(call Package/unbound/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= (library)
  DEPENDS+= +libpthread
endef

define Package/libunbound/description
  This package contains the Unbound shared library.
endef

CONFIGURE_ARGS += \
	--disable-dsa \
	--disable-gost \
	--enable-allsymbols \
	--with-libexpat="$(STAGING_DIR)/usr" \
	--with-ssl="$(STAGING_DIR)/usr" \
	--with-pidfile=/var/run/unbound.pid \
	--with-user=unbound

define Package/unbound/conffiles
/etc/config/unbound
/etc/unbound/unbound.conf
/etc/unbound/unbound_ext.conf
/etc/unbound/unbound_srv.conf
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/unbound.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libunbound.{so*,a,la} $(1)/usr/lib/
endef

define Package/unbound/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/sbin/unbound \
		$(PKG_INSTALL_DIR)/usr/sbin/unbound-checkconf \
		$(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/unbound
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/etc/unbound/unbound.conf \
		$(1)/etc/unbound/unbound.conf
	$(INSTALL_DATA) ./files/root.key $(1)/etc/unbound/root.key
	$(INSTALL_DATA) ./files/unbound_ext.conf $(1)/etc/unbound/unbound_ext.conf
	$(INSTALL_DATA) ./files/unbound_srv.conf $(1)/etc/unbound/unbound_srv.conf
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/unbound.uci $(1)/etc/config/unbound
	$(INSTALL_DIR) $(1)/etc/hotplug.d/ntp
	$(INSTALL_BIN)  ./files/unbound.ntpd $(1)/etc/hotplug.d/ntp/25-unbound
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN)  ./files/unbound.init $(1)/etc/init.d/unbound
	$(INSTALL_DIR) $(1)/usr/lib/unbound
	$(INSTALL_BIN)  ./files/odhcpd.sh $(1)/usr/lib/unbound/odhcpd.sh
	$(INSTALL_DATA) ./files/odhcpd.awk $(1)/usr/lib/unbound/odhcpd.awk
	$(INSTALL_DATA) ./files/dnsmasq.sh $(1)/usr/lib/unbound/dnsmasq.sh
	$(INSTALL_DATA) ./files/iptools.sh $(1)/usr/lib/unbound/iptools.sh
	$(INSTALL_DATA) ./files/rootzone.sh $(1)/usr/lib/unbound/rootzone.sh
	$(INSTALL_DATA) ./files/unbound.sh $(1)/usr/lib/unbound/unbound.sh
endef

define Package/unbound-anchor/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/unbound-anchor $(1)/usr/sbin/
endef

define Package/unbound-control/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/unbound-control $(1)/usr/sbin/
endef

define Package/unbound-control-setup/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/unbound-control-setup $(1)/usr/sbin/
endef

define Package/unbound-host/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/unbound-host $(1)/usr/sbin/
endef

define Package/libunbound/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libunbound.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,unbound))
$(eval $(call BuildPackage,unbound-anchor))
$(eval $(call BuildPackage,unbound-control))
$(eval $(call BuildPackage,unbound-control-setup))
$(eval $(call BuildPackage,unbound-host))
$(eval $(call BuildPackage,libunbound))

