# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=getdns
PKG_VERSION:=1.7.3
PKG_RELEASE:=3

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://getdnsapi.net/dist/
PKG_HASH:=f1404ca250f02e37a118aa00cf0ec2cbe11896e060c6d369c6761baea7d55a2c

CMAKE_INSTALL:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_GETDNS_BUILD_LIBEVENT2 \
	CONFIG_GETDNS_ENABLE_STUB_ONLY \
	CONFIG_GETDNS_ENABLE_IDN_LIBIDN2

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/getdns/Default
  TITLE:=getdns (library) using $(2)
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=https://getdnsapi.net/
  DEPENDS:=$(3) \
	   +GETDNS_BUILD_LIBEVENT2:libevent2 \
	   +!GETDNS_ENABLE_STUB_ONLY:libunbound \
	   +GETDNS_ENABLE_IDN_LIBIDN2:libidn2
  VARIANT:=$(1)
  DEFAULT_VARIANT:=$(4)
  PROVIDES:=getdns
  CONFLICTS:=$(5)
  MENU:=1
endef

Package/getdns-openssl=$(call Package/getdns/Default,openssl,OpenSSL,+PACKAGE_getdns-openssl:libopenssl,1,getdns-mbedtls)
Package/getdns-mbedtls=$(call Package/getdns/Default,mbedtls,mbedTLS,+PACKAGE_getdns-mbedtls:libmbedtls,,)

define Package/getdns/description
	This package contains the getdns library (libgetdns).
	This package also contains the "getdns_query" command line wrapper for getdns exposing the features of this implementation (both in the official API and the additional API functions).
endef

Package/getdns-openssl/description=$(Package/getdns/description)
Package/getdns-mbedtls/description=$(Package/getdns/description)

define Package/getdns/config/Default
	source "$(SOURCE)/Config.in"
endef

Package/getdns-openssl/config=$(Package/getdns/config/Default)
Package/getdns-mbedtls/config=$(Package/getdns/config/Default)

# CMAKE options for GetDNS are described in this document:
# https://getdnsapi.net/quick-start/cmake-quick-start/
CMAKE_OPTIONS += -DBUILD_LIBEV=OFF
CMAKE_OPTIONS += -DBUILD_LIBUV=OFF

CMAKE_OPTIONS += -DBUILD_LIBEVENT2=$(if $(CONFIG_GETDNS_BUILD_LIBEVENT2),ON,OFF)
CMAKE_OPTIONS += -DENABLE_STUB_ONLY=$(if $(CONFIG_GETDNS_ENABLE_STUB_ONLY),ON,OFF)
CMAKE_OPTIONS += -DUSE_LIBIDN2=$(if $(CONFIG_GETDNS_ENABLE_IDN_LIBIDN2),ON,OFF)

# getdns will use libbsd for the functions inet_pton, inet_ntop, strlcpy if
# present, otherwise it will use builtin code for these functions. In order to
# force the use of the built in code and remove the libbsd dependency disable
# the test for libbsd.
CMAKE_OPTIONS += -DBSD_LIBRARY=OFF

# Disable static linking to ensure that utility programs such as getdns_query
# don't end up as large statically linked binaries.
CMAKE_OPTIONS += -DENABLE_STATIC=OFF
CMAKE_OPTIONS += -DENABLE_SHARED=ON  # This is the default

ifeq ($(BUILD_VARIANT),mbedtls)
  CMAKE_OPTIONS += -DUSE_MBEDTLS=ON
  CMAKE_OPTIONS += -DHAVE_MBEDTLS=ON
endif

define Package/getdns/install/Default
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgetdns.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/getdns_query $(1)/usr/sbin/getdns_query
endef

Package/getdns-openssl/install=$(Package/getdns/install/Default)
Package/getdns-mbedtls/install=$(Package/getdns/install/Default)

$(eval $(call BuildPackage,getdns-openssl))
$(eval $(call BuildPackage,getdns-mbedtls))
