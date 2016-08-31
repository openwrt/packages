#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=portmap
PKG_VERSION:=6.0
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://neil.brown.name/portmap/
PKG_MD5SUM:=ac108ab68bf0f34477f8317791aaf1ff

PKG_LICENSE:=BSD-4c
PKG_LICENSE_FILES:=portmap.man

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/portmap
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libwrap $(LIBRPC_DEPENDS)
  TITLE:=The RPC Portmapper
  URL:=http://neil.brown.name/portmap/
  MAINTAINER:=Peter Wagner <tripolar@gmx.at>
  USERID:=rpc=65533:rpc=65533
endef

define Package/portmap/description
 Portmap is a server that converts RPC (Remote Procedure Call) program
 numbers into DARPA protocol port numbers.
endef

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) -DHOSTS_ACCESS -DFACILITY=LOG_DAEMON -DIGNORE_SIGCHLD" \
	RPCUSER="rpc" \
	LDLIBS="$(TARGET_LDFLAGS) -lwrap $(LIBRPC)" \
	all

define Package/portmap/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/portmap $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/portmap.init $(1)/etc/init.d/portmap
endef

$(eval $(call BuildPackage,portmap))
