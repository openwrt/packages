#
# Copyright (C) 2019 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#
include $(TOPDIR)/rules.mk

PKG_NAME:=czmq
PKG_VERSION:=4.2.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/zeromq/czmq/releases/download/v$(PKG_VERSION)/
PKG_HASH:=cfab29c2b3cc8a845749758a51e1dd5f5160c1ef57e2a41ea96e4c2dcc8feceb

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

PKG_LICENSE:=MPLv2
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>

PKG_ABI_VERSION:=4

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/autotools.mk

define Package/czmq
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=CZMQ High-level C binding for ZeroMQ
	URL:=http://czmq.zeromq.org
	ABI_VERSION:=$(PKG_ABI_VERSION)
	DEPENDS:=+libzmq +libuuid +libpcre +libmicrohttpd +liblz4 +libcurl
endef

define Package/czmq/description
  High-level C binding for ZeroMQ which is high-performance asynchronous messaging
  library, aimed at use in distributed or concurrent applications.
endef

TARGET_CFLAGS += --std=c99
CONFIGURE_ARGS += --without-docs

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
endef

define Package/czmq/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/zmakecert $(1)/usr/bin/zmakecert
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libczmq.so.$(PKG_VERSION) $(1)/usr/lib/
	$(LN) /usr/lib/libczmq.so.$(PKG_VERSION) $(1)/usr/lib/libczmq.so
	$(LN) /usr/lib/libczmq.so.$(PKG_VERSION) $(1)/usr/lib/libczmq.so.$(PKG_ABI_VERSION)
endef

$(eval $(call BuildPackage,czmq))
