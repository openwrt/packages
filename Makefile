# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile 5624 2006-11-23 00:29:07Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=batman-III
PKG_VERSION:=0.2.0a
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tbz2
PKG_SOURCE_URL:=http://downloads.open-mesh.net/batman
PKG_MD5SUM:=d5ac8329633590ed072a6b7ecccacf0b
PKG_CAT:=bzcat

PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/package.mk

define Package/batman
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpthread +kmod-tun
  TITLE:=B.A.T.M.A.N. Better Approach To Mobile Ad-hoc Networking
  URL:=https://www.open-mesh.net/
endef

define Build/Configure
endef

define Build/Compile
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C "$(PKG_BUILD_DIR)" \
		$(TARGET_CONFIGURE_OPTS) \
		NODEBUG=1 \
		OFLAGS="$(TARGET_CFLAGS)" \
		OS="linux" \
		INSTALL_PREFIX="$(PKG_INSTALL_DIR)" \
		STRIP="/bin/true" \
		batmand install
endef

define Package/batman/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/batmand $(1)/usr/sbin/
	$(CP) -a ./files/* $(1)/
	chmod -R 755 $(1)/etc/init.d/batman
endef


$(eval $(call BuildPackage,batman))
