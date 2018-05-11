# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=getdns
PKG_VERSION:=1.4.2
PKG_RELEASE:=1

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=David Mora <iamperson347+public@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://getdnsapi.net/dist/
PKG_HASH:=1685b82dfe297cffc4bae08a773cdc88a3edf9a4e5a1ea27d8764bb5affc0e80

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_GETDNS_ENABLE_STUB_ONLY \
	CONFIG_GETDNS_ENABLE_IDN_LIBIDN2 
	
include $(INCLUDE_DIR)/package.mk

define Package/getdns/Default
	TITLE:=getdns
	URL:=https://getdnsapi.net/
endef

define Package/getdns
	$(call Package/getdns/Default)
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE+= (library)
	DEPENDS+= +libopenssl +!GETDNS_ENABLE_STUB_ONLY:libunbound +GETDNS_ENABLE_IDN_LIBIDN2:libidn2
	MENU:=1
endef

define Package/getdns/description
	This package contains the getdns library (libgetdns). 
	This package also contains the "getdns_query" command line wrapper for getdns exposing the features of this implementation (both in the official API and the additional API functions).
endef

define Package/getdns/config
	source "$(SOURCE)/Config.in"
endef

CONFIGURE_ARGS += \
		$(if $(CONFIG_GETDNS_ENABLE_STUB_ONLY), --enable-stub-only, ) \
		--without-libidn \
		$(if $(CONFIG_GETDNS_ENABLE_IDN_LIBIDN2), , --without-libidn2 ) \
		--with-ssl="$(STAGING_DIR)/usr" \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/getdns/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/getdns/getdns*.h $(1)/usr/include/getdns/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgetdns*.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/getdns*.pc $(1)/usr/lib/pkgconfig/
endef
	
	
define Package/getdns/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libgetdns.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/sbin	
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/getdns_query $(1)/usr/sbin/getdns_query
endef

$(eval $(call BuildPackage,getdns))
