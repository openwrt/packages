#
# Copyright (C) 2007-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iperf
PKG_VERSION:=3.20
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://downloads.es.net/pub/iperf
PKG_HASH:=3acc572d1ecca4e0b20359c7bf0132ddc80d982efeee20c86f6726a9a6094388

PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>
PKG_LICENSE:=BSD-3-Clause
PKG_CPE_ID:=cpe:/a:es:iperf3

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

DISABLE_NLS:=

define Package/iperf3
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Internet Protocol bandwidth measuring tool
  URL:=https://github.com/esnet/iperf
  DEPENDS:=+libiperf3
endef

define Package/iperf3/config
menu "Configuration"
	depends on PACKAGE_iperf3

config PACKAGE_iperf3_SSL_SUPPORT
	bool "SSL support (iperf_auth)"
	default n
endmenu
endef

define Package/libiperf3
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Internet Protocol bandwidth measuring library
  URL:=https://github.com/esnet/iperf
  DEPENDS:=+libatomic +PACKAGE_iperf3_SSL_SUPPORT:libopenssl
endef

define Package/libiperf3/config
menu "Configuration"
	depends on PACKAGE_libiperf3

config PACKAGE_iperf3_SSL_SUPPORT
	bool "SSL support (iperf_auth)"
	default n
endmenu
endef

TARGET_CFLAGS += -D_GNU_SOURCE
TARGET_LDFLAGS += -latomic

ifeq ($(CONFIG_PACKAGE_iperf3_SSL_SUPPORT),y)
	CONFIGURE_ARGS += --with-openssl="$(STAGING_DIR)/usr"
else
	CONFIGURE_ARGS += --without-openssl
endif

CONFIGURE_ARGS += --without-sctp

MAKE_FLAGS += noinst_PROGRAMS=

define Package/iperf3/description
 Iperf is a modern alternative for measuring TCP and UDP bandwidth
 performance, allowing the tuning of various parameters and
 characteristics.
endef

define Package/libiperf3/description
 Libiperf is a library providing an API for iperf3 functionality.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libiperf.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
endef

define Package/iperf3/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/iperf3 $(1)/usr/bin/
endef

define Package/libiperf3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libiperf.so.* $(1)/usr/lib
endef

$(eval $(call BuildPackage,iperf3))
$(eval $(call BuildPackage,libiperf3))
