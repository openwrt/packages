#
# Copyright (C) 2008 Freifunk Leipzig
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id$

include $(TOPDIR)/rules.mk

PKG_NAME:=bmxd
PKG_SOURCE_URL:=http://downloads.open-mesh.net/svn/batman/trunk/batman-experimental/

PKG_REV:=1075
PKG_VERSION:=r$(PKG_REV)
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=svn
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

include $(INCLUDE_DIR)/package.mk

define Package/bmxd/Default
  URL:=https://www.open-mesh.net/
endef

define Package/bmxd
$(call Package/bmxd/Default)
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpthread +kmod-tun
  TITLE:=B.A.T.M.A.N. Experimental (BMX) layer 3 routing daemon
endef

define Package/bmxd/description
B.A.T.M.A.N. Experimental (BMX) layer 3 routing daemon
endef

MAKE_ARGS += \
	EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
	CCFLAGS="$(TARGET_CFLAGS)" \
	OFLAGS="$(TARGET_CFLAGS)" \
	REVISION="$(PKG_REV)" \
	CC="$(TARGET_CC)" \
	NODEBUG=1 \
	UNAME="Linux" \
	INSTALL_DIR="$(PKG_INSTALL_DIR)" \
	STRIP="/bin/true" \
	batmand install

define Build/Configure
	mkdir -p $(PKG_INSTALL_DIR)/bin
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_ARGS)
endef

define Package/bmxd/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/batmand $(1)/usr/sbin/bmxd
	$(INSTALL_BIN) ./files/etc/init.d/bmxd $(1)/etc/init.d
	$(INSTALL_DATA) ./files/etc/config/bmxd $(1)/etc/config
endef

$(eval $(call BuildPackage,bmxd))
