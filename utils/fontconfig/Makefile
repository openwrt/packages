#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fontconfig
PKG_VERSION:=2.11.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://fontconfig.org/release/
PKG_HASH:=dc62447533bca844463a3c3fd4083b57c90f18a70506e7a9f4936b5a1e516a99

PKG_CPE_ID:=cpe:/a:fontconfig_project:fontconfig

PKG_FIXUP:=libtool
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/fontconfig
  SECTION:=xorg-util
  CATEGORY:=Xorg
  SUBMENU:=font-utils
  TITLE:=fontconfig
  DEPENDS:=+libpthread +libexpat +libfreetype
  URL:=http://fontconfig.org/
endef

#TODO: better put cache on persistent storage for faster boot time?
CONFIGURE_ARGS+= \
	--with-cache-dir=/tmp/fontconfig/cache \
	--with-arch=$(ARCH) \
	--disable-iconv \
	--disable-libxml2 \
	--disable-docs

CONFIGURE_VARS+= \
	ac_cv_prog_HASDOCBOOK=no \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/fontconfig $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfontconfig.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/fontconfig.pc $(1)/usr/lib/pkgconfig/
endef

define Package/fontconfig/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib $(1)/usr/share/fontconfig/conf.avail
	$(INSTALL_DIR) $(1)/etc/fonts/conf.d
	$(CP) $(PKG_INSTALL_DIR)/etc/fonts/fonts.conf $(1)/etc/fonts
	$(CP) $(PKG_INSTALL_DIR)/etc/fonts/conf.d/* $(1)/etc/fonts/conf.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/fontconfig/conf.avail/* $(1)/usr/share/fontconfig/conf.avail
	$(INSTALL_DIR) $(1)/etc/init.d
#	$(INSTALL_BIN) ./files/fontconfig.init $(1)/etc/init.d/fontconfig
endef

$(eval $(call BuildPackage,fontconfig))
