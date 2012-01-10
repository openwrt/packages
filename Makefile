#
# Copyright (C) 2008 Freifunk Leipzig
# Copyright (C) 2008-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bmxd

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@github.com:axn/bmxd.git
PKG_REV:=9c1d12b554dccd2efde249f5e44a7d4de59ce1a8
PKG_VERSION:=r2012011001
#PKG_RELEASE:=1
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

PKG_EXTRA_CFLAGS:=-DNODEBUGALL


include $(INCLUDE_DIR)/package.mk

define Package/bmxd/Default
  URL:=http://www.bmx6.net/
  MAINTAINER:=Axel Neumann <neumann@cgws.de>
endef

define Package/bmxd
$(call Package/bmxd/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  DEPENDS:=+kmod-tun
  TITLE:=B.a.t.M.a.n. eXperimental (BMX) layer 3 routing daemon
endef

define Package/bmxd/conffiles
/etc/config/bmxd
endef


define Package/bmxd/description
B.a.t.M.a.n. eXperimental (BMX) layer 3 routing daemon
endef

MAKE_ARGS += \
	EXTRA_CFLAGS="$(TARGET_CFLAGS) $(PKG_EXTRA_CFLAGS)" \
	CCFLAGS="$(TARGET_CFLAGS)" \
	OFLAGS="$(TARGET_CFLAGS)" \
	REVISION="$(PKG_REV)" \
	CC="$(TARGET_CC)" \
	NODEBUG=1 \
	UNAME="Linux" \
	INSTALL_PREFIX="$(PKG_INSTALL_DIR)" \
	STRIP="/bin/true" \
	bmxd install

define Build/Compile
	mkdir -p $(PKG_INSTALL_DIR)/usr/sbin
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_ARGS)
endef

define Package/bmxd/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/bmxd $(1)/usr/sbin/bmxd
	$(INSTALL_BIN) ./files/etc/init.d/bmxd $(1)/etc/init.d
	$(INSTALL_DATA) ./files/etc/config/bmxd $(1)/etc/config
endef

$(eval $(call BuildPackage,bmxd))
