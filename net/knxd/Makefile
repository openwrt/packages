#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

### Remarks
### 'python pascal ruby lua' need to be deleted in src/clients/Makefile.am

include $(TOPDIR)/rules.mk

PKG_NAME:=knxd
PKG_VERSION=2016-10-08
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/knxd/knxd.git
PKG_SOURCE_VERSION:=43e90c6ee3028194c8ce6d7776e7dedbe1032dc1
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz

PKG_MAINTAINER:=Othmar Truniger <github@truniger.ch>

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS:=argp-standalone

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/knxd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=EIB KNX daemon
  DEPENDS:=+pthsem +libusb-1.0
endef

define Package/knxd/description
EIB KNX Daemon
endef

define Package/knxd/conffiles
/etc/config/knxd
endef

define Package/knxd-tools
  SECTION:=net
  CATEGORY:=Network
  TITLE:=EIB KNX Utils
endef

define Package/knxd-tools/description
EIB KNX Tools
endef

TARGET_CXXFLAGS+= -fno-rtti
TARGET_CXX=$(TARGET_CC)

CONFIGURE_ARGS+= \
	--disable-ft12 \
	--enable-eibnetip \
	--enable-eibnetiptunnel \
	--enable-eibnetipserver \
	--enable-usb \
	--enable-tpuarts \
	--disable-pei16s \
	--enable-groupcache \
	--without-pth-test \
	--disable-systemd \
	--without-libstdc

EXTRA_LDFLAGS+= \
       -fno-builtin -largp

define Package/knxd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(RM) $(1)/usr/bin/knxtool

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/knxd.init $(1)/etc/init.d/knxd

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/knxd.config $(1)/etc/config/knxd
endef

define Package/knxd-tools/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libeibclient.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/knxtool $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/knxd/eibwrite-cgi $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/knxd/eibread-cgi $(1)/usr/bin/
endef

$(eval $(call BuildPackage,knxd))
$(eval $(call BuildPackage,knxd-tools))
