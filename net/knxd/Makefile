#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

### Remarks
### 'python pascal ruby lua' need to be deleted in src/clients/Makefile.am

include $(TOPDIR)/rules.mk

PKG_NAME:=knxd
PKG_VERSION=2015-03-31-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/knxd/knxd.git
PKG_SOURCE_VERSION:=2c6c6732a684dffb87b391ea92cccdf07c8385b8
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

define Package/libeibclient
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for EIB clients
  DEPENDS:=+pthsem
endef

define Package/libeibclient/description
EIB KNX client library
endef

define Package/knxd-tools
  SECTION:=net
  CATEGORY:=Network
  TITLE:=EIB KNX Utils
  DEPENDS:=+libeibclient
endef

define Package/knxd-tools/description
EIB KNX Tools
endef

CONFIGURE_ARGS+= \
	--disable-ft12 \
	--enable-eibnetip \
	--enable-eibnetiptunnel \
	--enable-eibnetipserver \
	--enable-usb \
	--enable-tpuart \
	--enable-tpuarts \
	--disable-pei16 \
	--disable-pei16s \
	--enable-groupcache \
	--without-pth-test \
	--without-libstdc

EXTRA_LDFLAGS+= \
	-fno-builtin -nodefaultlibs -lc -lgcc

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/eib*.h $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libeibclient.{a,so*} $(1)/usr/lib/
endef

define Package/knxd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/knxd.init $(1)/etc/init.d/knxd

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/knxd.config $(1)/etc/config/knxd
endef

define Package/libeibclient/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libeibclient.so* $(1)/usr/lib/
endef

define Package/knxd-tools/install
	$(INSTALL_DIR) $(1)/usr/bin

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/knxtool $(1)/usr/bin/
	ln -sf knxtool $(1)/usr/bin/knxread
	ln -sf knxtool $(1)/usr/bin/knxreadtemp
	ln -sf knxtool $(1)/usr/bin/knxwrite
	ln -sf knxtool $(1)/usr/bin/knxlog
	ln -sf knxtool $(1)/usr/bin/knxon
	ln -sf knxtool $(1)/usr/bin/knxoff
	ln -sf knxtool $(1)/usr/bin/knxif
	ln -sf knxtool $(1)/usr/bin/knxswrite
	ln -sf knxtool $(1)/usr/bin/knxbool
	ln -sf knxtool $(1)/usr/bin/knxdimup

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/busmonitor1 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/busmonitor2 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/busmonitor3 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/eibread-cgi $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/eibwrite-cgi $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/vbusmonitor1 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/vbusmonitor2 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/vbusmonitor3 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/groupwrite $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/groupswrite $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/grouplisten $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/groupread $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/groupresponse $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/groupreadresponse $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/groupsocketlisten $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/groupsocketread $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/groupsocketwrite $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/knxd/examples/bin/groupsocketswrite $(1)/usr/bin/
endef

$(eval $(call BuildPackage,knxd))
$(eval $(call BuildPackage,libeibclient))
$(eval $(call BuildPackage,knxd-tools))
