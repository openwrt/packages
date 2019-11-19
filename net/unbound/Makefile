#
# Copyright (C) 2010-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=unbound
PKG_VERSION:=1.9.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://nlnetlabs.nl/downloads/unbound
PKG_HASH:=8a8d400f697c61d73d109c250743a1b6b79848297848026d82b43e831045db57

PKG_MAINTAINER:=Eric Luehrsen <ericluehrsen@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:nlnetlabs:unbound

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/unbound/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  USERID:=unbound:unbound
  TITLE:=Recursive DNS Server
  URL:=https://nlnetlabs.nl/projects/unbound/about
  DEPENDS:=+libopenssl +@OPENSSL_WITH_EC
endef

define Package/unbound-daemon
  $(call Package/unbound/Default)
  TITLE+= (daemon, light traffic)
  DEPENDS+= +libunbound
  VARIANT:=light
endef

define Package/unbound-daemon/description
  This package contains the Unbound daemon with basic includes
  necessary to meet the needs of UCI/LuCI configuration optoins.
endef

define Package/unbound-daemon-heavy
  $(call Package/unbound/Default)
  TITLE+= (daemon, heavy traffic)
  URL:=https://nlnetlabs.nl/documentation/unbound/howto-optimise
  DEPENDS+= +libunbound-heavy +libpthread +libevent2 +libevent2-pthreads
  VARIANT:=heavy
  PROVIDES:=unbound-daemon
endef

define Package/unbound-daemon-heavy/description
  This package contains the Unbound daemon including 'libevent' and
  'libpthread' to better handle large networks with heavy query loads.
endef

define Package/libunbound
  $(call Package/unbound/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Networking
  TITLE+= (library, light traffic)
  VARIANT:=light
  DEFAULT_VARIANT:=1
endef

define Package/libunbound/description
  This package contains the Unbound shared library with basic includes
  necessary to meet the needs of UCI/LuCI configuration optoins.
endef

define Package/libunbound-heavy
  $(call Package/unbound/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Networking
  TITLE+= (library, heavy traffic)
  URL:=https://nlnetlabs.nl/documentation/unbound/howto-optimise
  DEPENDS+= +libpthread +libevent2 +libevent2-pthreads
  VARIANT:=heavy
  PROVIDES:=libunbound
endef

define Package/libunbound-heavy/description
  This package contains the Unbound shared library including 'libevent' and
  'libpthread' to better handle large networks with heavy query loads.
endef

define Package/unbound-anchor
  $(call Package/unbound/Default)
  TITLE+= (root DSKEY)
  DEPENDS+= +unbound-daemon +libexpat
endef

define Package/unbound-anchor/description
  This package contains the Unbound anchor utility.
endef

define Package/unbound-checkconf
  $(call Package/unbound/Default)
  TITLE+= (config checker)
  DEPENDS+= +unbound-daemon
endef

define Package/unbound-checkconf/description
  This package contains the Unbound DNS configuration checker utility.
endef

define Package/unbound-control
  $(call Package/unbound/Default)
  TITLE+= (remote control)
  DEPENDS+= +unbound-daemon
endef

define Package/unbound-control/description
  This package contains the Unbound control utility.
endef

define Package/unbound-control-setup
  $(call Package/unbound/Default)
  TITLE+= (control setup)
  DEPENDS+= +unbound-control +openssl-util
endef

define Package/unbound-control-setup/description
  This package contains the Unbound control setup utility.
endef

define Package/unbound-host
  $(call Package/unbound/Default)
  TITLE+= (DNS lookup)
  DEPENDS+= +libunbound
endef

define Package/unbound-host/description
  This package contains the Unbound DNS lookup utility.
endef

CONFIGURE_ARGS += \
	--disable-dsa \
	--disable-gost \
	--enable-allsymbols \
	--enable-ecdsa \
	--enable-tfo-client \
	--enable-tfo-server \
	--with-libexpat="$(STAGING_DIR)/usr" \
	--with-ssl="$(STAGING_DIR)/usr" \
	--with-user=unbound \
	--with-run-dir=/var/lib/unbound \
	--with-conf-file=/var/lib/unbound/unbound.conf \
	--with-pidfile=/var/run/unbound.pid

ifeq ($(BUILD_VARIANT),heavy)
	CONFIGURE_ARGS += \
		--with-pthreads \
		--with-libevent="$(STAGING_DIR)/usr" \
		--enable-event-api
else
    CONFIGURE_ARGS += \
		--without-pthreads \
		--without-solaris-threads \
		--without-libevent
endif

define Package/unbound-daemon/conffiles
/etc/config/unbound
/etc/unbound/unbound.conf
/etc/unbound/unbound_ext.conf
/etc/unbound/unbound_srv.conf
endef

Package/unbound-daemon-heavy/conffiles = $(Package/unbound-daemon/conffiles)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libunbound.{so*,a,la} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/unbound.h $(1)/usr/include/
ifeq ($(BUILD_VARIANT),heavy)
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/unbound-event.h $(1)/usr/include/
endif
endef

define Package/unbound-daemon/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/sbin/unbound $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/unbound
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/var/lib/unbound/unbound.conf \
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
	$(INSTALL_DATA) ./files/defaults.sh $(1)/usr/lib/unbound/defaults.sh
	$(INSTALL_DATA) ./files/dnsmasq.sh $(1)/usr/lib/unbound/dnsmasq.sh
	$(INSTALL_DATA) ./files/iptools.sh $(1)/usr/lib/unbound/iptools.sh
	$(INSTALL_BIN)  ./files/odhcpd.sh $(1)/usr/lib/unbound/odhcpd.sh
	$(INSTALL_DATA) ./files/odhcpd.awk $(1)/usr/lib/unbound/odhcpd.awk
	$(INSTALL_DATA) ./files/stopping.sh $(1)/usr/lib/unbound/stopping.sh
	$(INSTALL_DATA) ./files/unbound.sh $(1)/usr/lib/unbound/unbound.sh
endef

Package/unbound-daemon-heavy/install = $(Package/unbound-daemon/install)

define Package/libunbound/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libunbound.so.* $(1)/usr/lib/
endef

Package/libunbound-heavy/install = $(Package/libunbound/install)

define Package/unbound-anchor/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/unbound-anchor $(1)/usr/sbin/
endef

define Package/unbound-checkconf/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/unbound-checkconf $(1)/usr/sbin/
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

$(eval $(call BuildPackage,unbound-daemon))
$(eval $(call BuildPackage,unbound-daemon-heavy))
$(eval $(call BuildPackage,libunbound))
$(eval $(call BuildPackage,libunbound-heavy))
$(eval $(call BuildPackage,unbound-anchor))
$(eval $(call BuildPackage,unbound-checkconf))
$(eval $(call BuildPackage,unbound-control))
$(eval $(call BuildPackage,unbound-control-setup))
$(eval $(call BuildPackage,unbound-host))

