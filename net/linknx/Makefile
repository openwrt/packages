#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=linknx
PKG_VERSION:=0.0.1.33
PKG_RELEASE:=2

PKG_MAINTAINER:=Othmar Truniger <github@truniger.ch>
PKG_LICENSE:=GPL-2.0+

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/linknx/linknx.git
PKG_SOURCE_VERSION:=6166831eff645f21a7fd22ec3f7855f36005b8d9
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE:=$(PKG_NAME)-${PKG_VERSION}.tar.xz
PKG_MIRROR_HASH:=9d38d3a5b4bd935f841fbacf0ee00a9bb9e75ac7a7e7609864254ebb5bbdb960

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS:=argp-standalone
PKG_FORTIFY_SOURCE:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/linknx
  SECTION:=net
  CATEGORY:=Network
  TITLE:=KNX home automation platform
  URL:=http://sourceforge.net/projects/linknx/
  DEPENDS:=+pthsem +lua +luac +libstdcpp +libcurl +libesmtp
endef

CONFIGURE_ARGS+= \
	--verbose \
	--without-pth-test \
	--without-log4cpp \
	--with-lua \
	--with-libcurl \
	--without-mysql

EXTRA_LDFLAGS+= \
	-fno-builtin

define Package/linknx/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/linknx $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/linknx.init $(1)/etc/init.d/linknx
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/linknx.config $(1)/etc/config/linknx
	$(INSTALL_DATA) ./files/linknx.xml.dist $(1)/etc/linknx.xml.dist
	$(INSTALL_DIR) $(1)/tmp/linknx/persist
endef

define Package/linknx/conffiles
/etc/config/linknx
/etc/linknx.xml.dist
endef

$(eval $(call BuildPackage,linknx))
