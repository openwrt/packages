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
PKG_REV:=9cdcf0f25d34ed7939ecc41029caf6213581baa8
PKG_VERSION:=2015-02-13
PKG_RELEASE:=1

PKG_MAINTAINER:=Othmar Truniger <github@truniger.ch>
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=LICENSE


PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/Makki1/knxd.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS:=pthsem argp-standalone

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/knxd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Eib KNX deamon
  URL:=https://github.com/Makki1/knxd
  DEPENDS:=pthsem libusb-1.0
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
  TITLE:=Eib KNX Utils
  URL:=https://github.com/Makki1/knxd
  DEPENDS:=pthsem libusb-1.0
endef

define Package/knxd-tools/description
EIB KNX Tools
endef

define Build/Prepare
	$(call Build/Prepare/Default)
endef

define Build/Configure
	$(call Build/Configure/Default,\
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
		--without-libstdc )
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC=$(TARGET_CC) \
		LIBS="-L$(STAGING_DIR)/lib -L$(STAGING_DIR)/usr/lib -fno-builtin -nodefaultlibs -lc -lm -lgcc -largp -lpthsem" \
		CPPFLAGS="-I$(STAGING_DIR)/include -I$(STAGING_DIR)/usr/include"
endef

define Package/knxd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/server/knxd $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/tools/bcu/bcuaddrtab $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/tools/bcu/bcuread $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/tools/eibnet/eibnetsearch $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/tools/eibnet/eibnetdescribe $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/usb/findknxusb $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/knxd.init $(1)/etc/init.d/knxd
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/knxd.config $(1)/etc/config/knxd
endef

define Package/knxd-tools/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/client/c/.libs/libeibclient.so.0.0.0 $(1)/usr/lib/
	ln -s libeibclient.so.0.0.0 $(1)/usr/lib/libeibclient.so
	ln -s libeibclient.so.0.0.0 $(1)/usr/lib/libeibclient.so.0
	$(INSTALL_DIR) $(1)/usr/bin
	-rm -f $(1)/usr/bin/knxread
	-rm -f $(1)/usr/bin/knxreadtemp
	-rm -f $(1)/usr/bin/knxwrite
	-rm -f $(1)/usr/bin/knxlog
	-rm -f $(1)/usr/bin/knxon
	-rm -f $(1)/usr/bin/knxoff
	-rm -f $(1)/usr/bin/knxif
	-rm -f $(1)/usr/bin/knxswrite
	-rm -f $(1)/usr/bin/knxbool
	-rm -f $(1)/usr/bin/knxdimup
	ln -s knxtool $(1)/usr/bin/knxread
	ln -s knxtool $(1)/usr/bin/knxreadtemp
	ln -s knxtool $(1)/usr/bin/knxwrite
	ln -s knxtool $(1)/usr/bin/knxlog
	ln -s knxtool $(1)/usr/bin/knxon
	ln -s knxtool $(1)/usr/bin/knxoff
	ln -s knxtool $(1)/usr/bin/knxif
	ln -s knxtool $(1)/usr/bin/knxswrite
	ln -s knxtool $(1)/usr/bin/knxbool
	ln -s knxtool $(1)/usr/bin/knxdimup
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/knxtool $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/busmonitor1 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/busmonitor2 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/busmonitor3 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/eibread-cgi $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/eibwrite-cgi $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/vbusmonitor1 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/vbusmonitor2 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/vbusmonitor3 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/groupwrite $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/groupswrite $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/grouplisten $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/groupread $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/groupresponse $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/groupreadresponse $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/groupsocketlisten $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/groupsocketread $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/groupsocketwrite $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/examples/.libs/groupsocketswrite $(1)/usr/bin/
endef

$(eval $(call BuildPackage,knxd))
$(eval $(call BuildPackage,knxd-tools))
