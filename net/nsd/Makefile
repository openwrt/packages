#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nsd
PKG_VERSION:=4.1.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.nlnetlabs.nl/downloads/nsd
PKG_MD5SUM:=73014bab5514b9babaf6c9007a6b36d8
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_LICENSE:=BSD-3c
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Vasilis Tsiligiannis <acinonyx@openwrt.gr>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/nsd/default
  TITLE:=NSD Name Server Daemon
  URL:=http://www.nlnetlabs.nl/projects/nsd/
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
endef

define Package/nsd/default/description
  NSD is an authoritative only, high performance, simple and open source name
  server.
endef

define Package/nsd
  $(Package/nsd/default)
  TITLE += (with SSL support)
  DEPENDS += +libopenssl
  VARIANT:=ssl
endef

define Package/nsd/description
  $(Package/nsd/default/description)
endef

define Package/nsd-nossl
  $(Package/nsd/default)
  TITLE += (without SSL support)
  VARIANT:=nossl
endef

define Package/nsd-nossl/description
  $(Package/nsd/default/description)
endef

define Package/nsd-checkconf/description
  $(Package/nsd/default/description)
endef

define Package/nsd-control
  $(Package/nsd/default)
  TITLE += remote control utility
  DEPENDS += +libopenssl
endef

define Package/nsd-control/description
  $(Package/nsd/default/description)
endef

define Package/nsd-control-setup
  $(Package/nsd/default)
  TITLE += SSL keys setup script
  DEPENDS += +openssl-util
endef

define Package/nsd-control-setup/description
  $(Package/nsd/default/description)
endef

CONFIGURE_ARGS+= \
	--disable-checking \
	--with-libevent=no \
	--with-user="network" \

CONFIGURE_VARS+= \
	ac_cv_c_va_list_def=no \
	ac_cv_c_strptime_needs_defs=no \

ifeq ($(BUILD_VARIANT),ssl)
	CONFIGURE_ARGS += \
		--with-ssl="$(STAGING_DIR)/usr"
endif

ifeq ($(BUILD_VARIANT),nossl)
	CONFIGURE_ARGS += \
		--without-ssl
endif

define Package/nsd/conffiles
/etc/nsd/
endef

define Package/nsd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/{nsd,nsd-checkconf} $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/nsd
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/nsd/nsd.conf.sample $(1)/etc/nsd/nsd.conf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nsd.init $(1)/etc/init.d/nsd
endef

define Package/nsd-control/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/nsd-control $(1)/usr/sbin/
endef

define Package/nsd-control-setup/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/nsd-control-setup $(1)/usr/sbin/
endef

Package/nsd-nossl/install = $(Package/nsd/install)
Package/nsd-nossl/conffiles = $(Package/nsd/conffiles)

$(eval $(call BuildPackage,nsd))
$(eval $(call BuildPackage,nsd-nossl))
$(eval $(call BuildPackage,nsd-control))
$(eval $(call BuildPackage,nsd-control-setup))
