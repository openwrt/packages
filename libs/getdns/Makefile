# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=getdns
PKG_VERSION:=1.6.0
PKG_RELEASE:=4

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jonathan Underwood <jonathan.underwood@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://getdnsapi.net/dist/
PKG_HASH:=40e5737471a3902ba8304b0fd63aa7c95802f66ebbc6eae53c487c8e8a380f4a

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_GETDNS_ENABLE_STUB_ONLY \
	CONFIG_GETDNS_ENABLE_IDN_LIBIDN2

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

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

# CMAKE options for GetDNS are described in this document:
# https://getdnsapi.net/quick-start/cmake-quick-start/
CMAKE_OPTIONS += -DBUILD_LIBEV=OFF
CMAKE_OPTIONS += -DBUILD_LIBEVENT2=OFF
CMAKE_OPTIONS += -DBUILD_LIBUV=OFF

CMAKE_OPTIONS += -DENABLE_STUB_ONLY=$(if $(CONFIG_GETDNS_ENABLE_STUB_ONLY),ON,OFF)
CMAKE_OPTIONS += -DUSE_LIBIDN2=$(if $(CONFIG_GETDNS_ENABLE_IDN_LIBIDN2),ON,OFF)

# getdns will use libbsd for the functions inet_pton, inet_ntop, strlcpy if
# present, otherwise it will use builtin code for these functions. In order to
# force the use of the built in code and remove the libbsd dependency disable
# the test for libbsd.
CMAKE_OPTIONS += -DBSD_LIBRARY=OFF

define Package/getdns/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgetdns.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/getdns_query $(1)/usr/sbin/getdns_query
endef

$(eval $(call BuildPackage,getdns))
