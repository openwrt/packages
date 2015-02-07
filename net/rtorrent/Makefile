#
# Copyright (C) 2007-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rtorrent
PKG_VERSION:=0.9.4-git-0
PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rakshasa/rtorrent.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=7343e33a6a0d279179b304a380bf011f1c8be64a
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/rtorrent/Default
  SUBMENU:=BitTorrent
  SECTION:=net
  CATEGORY:=Network
  TITLE:=BitTorrent client for ncurses
  URL:=http://libtorrent.rakshasa.no/
  DEPENDS:=+libcurl +libtorrent +libncursesw +libsigcxx +libpthread
  MAINTAINER:=Peter Wagner <tripolar@gmx.at>
endef

define Package/rtorrent/Default/description
 rTorrent is a BitTorrent client for ncurses, using the libtorrent library.
 The client and library is written in C++ with emphasis on speed and
 efficiency, while delivering equivalent features to those found in GUI based
 clients in an ncurses client.
endef

define Package/rtorrent
$(call Package/rtorrent/Default)
  VARIANT:=norpc
endef

define Package/rtorrent/description
$(call Package/rtorrent/Default/description)
 This package is built without xmlrpc support
endef

define Package/rtorrent-rpc
$(call Package/rtorrent/Default)
  VARIANT:=rpc
  DEPENDS+=+xmlrpc-c-server
  TITLE+=(with rpc support)
endef

define Package/rtorrent-rpc/description
$(call Package/rtorrent/Default/description)
 This package is built with xmlrpc support
endef

TARGET_LDFLAGS += -lz -lpthread -Wl,-rpath-link=$(STAGING_DIR)/usr/lib

CONFIGURE_ARGS+= \
	--enable-shared \
	--disable-static \
	--disable-debug

ifeq ($(BUILD_VARIANT),rpc)
	CONFIGURE_ARGS += \
		--with-xmlrpc-c
endif


define Package/rtorrent/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rtorrent $(1)/usr/bin/
endef

Package/rtorrent-rpc/install = $(Package/rtorrent/install)

$(eval $(call BuildPackage,rtorrent))
$(eval $(call BuildPackage,rtorrent-rpc))
