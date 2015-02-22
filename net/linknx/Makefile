#
# Copyright (C) 2008-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=linknx
PKG_VERSION:=0.0.1.32
PKG_RELEASE:=4
PKG_MD5SUM:=7ecc1208f59bceb05068c752b2250b63

PKG_MAINTAINER:=Othmar Truniger <github@truniger.ch>
PKG_LICENSE:=GPL-2.0+

PKG_SOURCE_URL:=@SF/linknx
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_BUILD_DEPENDS:=pthsem curl libesmtp

include $(INCLUDE_DIR)/package.mk

define Package/linknx
  SECTION:=net
  CATEGORY:=Network
  TITLE:=KNX home automation platform
  URL:=http://sourceforge.net/projects/linknx/
  DEPENDS:=pthsem +lua +luac +libstdcpp +libcurl +libesmtp
endef

define Build/Configure
	(cd $(PKG_BUILD_DIR); touch aclocal.m4 Makefile.in config.h.in configure; \
	$(SED) 's,\"2.0.4\",\"2.0.4\"\n_pth_version=\"2.0.8\",g' $(PKG_BUILD_DIR)/configure )
	$(call Build/Configure/Default,--verbose --without-pth-test --with-pth=$(STAGING_DIR) --without-log4cpp --with-lua --with-libcurl --without-mysql, \
	CXXFLAGS="$(TARGET_CFLAGS) -fno-builtin -lcrypt" \
	)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/ \
		LIBDIR="$(TARGET_LDFLAGS)" \
		CC="$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) " \
		LD="$(TARGET_CROSS)ld -shared" \
		LUA="$(STAGING_DIR_HOST)/bin/lua" \
		LUAC="$(STAGING_DIR_HOST)/bin/luac" \
		CFLAGS="$(TARGET_CFLAGS) -nodefaultlibs" all
endef

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
