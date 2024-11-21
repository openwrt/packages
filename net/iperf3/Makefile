#
# Copyright (C) 2007-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iperf
PKG_VERSION:=3.17.1
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://downloads.es.net/pub/iperf
PKG_HASH:=84404ca8431b595e86c473d8f23d8bb102810001f15feaf610effd3b318788aa

PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>
PKG_LICENSE:=BSD-3-Clause
PKG_CPE_ID:=cpe:/a:es:iperf3

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

DISABLE_NLS:=

define Package/iperf3/default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Internet Protocol bandwidth measuring tool
  URL:=https://github.com/esnet/iperf
endef

define Package/iperf3
$(call Package/iperf3/default)
  VARIANT:=nossl
  DEPENDS:=+libiperf3
endef

define Package/iperf3-ssl
$(call Package/iperf3/default)
  TITLE+= with iperf_auth support
  VARIANT:=ssl
  DEPENDS:=+libopenssl +libatomic
  CONFLICTS:=iperf3
endef

define Package/libiperf3
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Internet Protocol bandwidth measuring library
  URL:=https://github.com/esnet/iperf
  DEPENDS+=+libatomic
endef

TARGET_CFLAGS += -D_GNU_SOURCE
TARGET_LDFLAGS += -latomic

ifeq ($(BUILD_VARIANT),ssl)
	CONFIGURE_ARGS += --with-openssl="$(STAGING_DIR)/usr" --disable-shared
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

# autoreconf fails if the README file isn't present
define Build/Prepare
	$(call Build/Prepare/Default)
	touch $(PKG_BUILD_DIR)/README
endef

define Package/iperf3/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/iperf3 $(1)/usr/bin/
endef

define Package/iperf3-ssl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/iperf3 $(1)/usr/bin/
endef

define Package/libiperf3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libiperf.so.* $(1)/usr/lib
endef

$(eval $(call BuildPackage,iperf3))
$(eval $(call BuildPackage,iperf3-ssl))
$(eval $(call BuildPackage,libiperf3))
