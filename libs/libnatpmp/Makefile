#
# Copyright (C) 2011-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libnatpmp
PKG_VERSION:=20140401
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://miniupnp.free.fr/files
PKG_MD5SUM:=7c9a7c76e200ead4e6447fe4b105f676
PKG_MAINTAINER:=Hauke Mehrtens <hauke@hauke-m.de>
PKG_LICENSE:=BSD-3c
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libnatpmp/Default
  TITLE:=NAT Port Mapping Protocol (NAT-PMP)
  URL:=http://miniupnp.free.fr/libnatpmp.html
endef

define Package/libnatpmp/Default/description
  libnatpmp is an attempt to make a portable and fully compliant implementation
  of the protocol for the client side. It is based on non blocking sockets and
  all calls of the API are asynchronous. It is therefore very easy to integrate
  the NAT-PMP code to any event driven code.
endef

define Package/libnatpmp
  $(call Package/libnatpmp/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= library
endef

define Package/libnatpmp/description
  $(call Package/libnatpmp/Default/description)
  This package contains the shared library.
endef

define Package/natpmpc
  $(call Package/libnatpmp/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Firewall
  TITLE+= client
  DEPENDS:=+libnatpmp
endef

define Package/natpmpc/description
  $(call Package/libnatpmp/Default/description)
  This package contains the natpmp client.
endef

MAKE_FLAGS += \
	COPTS="$(TARGET_CFLAGS)" \
	PREFIX="$(PKG_INSTALL_DIR)" \
	OS="Linux"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/declspec.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/natpmp.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnatpmp*.{so*,a} $(1)/usr/lib/
endef

define Package/libnatpmp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libnatpmp.so.* $(1)/usr/lib/
endef

define Package/natpmpc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/natpmpc $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libnatpmp))
$(eval $(call BuildPackage,natpmpc))
