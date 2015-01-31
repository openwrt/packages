#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dansguardian
PKG_VERSION:=2.12.0.3
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Luka Perkov <luka@openwrt.org>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/dansguardian
PKG_MD5SUM:=2a88d0392cd28eaec02b7ee727b2e253

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/dansguardian
  SECTION:=net
  DEPENDS:=+libpthread $(CXX_DEPENDS) +zlib
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=DansGuardian
  URL:=http://dansguardian.org
endef

define Package/dansguardian/conffiles
/etc/dansguardian/dansguardianf1.conf
/etc/config/dansguardian
endef

CONFIGURE_VARS += \
	INCLUDES="" \
	CXXFLAGS="$$$$CXXFLAGS -fno-rtti" \
	LIBS="-lpthread" \

define Build/Configure
	$(call Build/Configure/Default,\
		--disable-clamav \
		--with-sysconfsubdir=dansguardian \
		--with-proxyuser=root \
		--with-proxygroup=root \
		--disable-pcre \
	)
endef

define Package/dansguardian/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/dansguardian $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc
	$(CP) $(PKG_INSTALL_DIR)/etc/dansguardian $(1)/etc/
	$(INSTALL_CONF) ./files/dansguardianf1.conf $(1)/etc/dansguardian/dansguardianf1.conf

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/dansguardian.config $(1)/etc/config/dansguardian

	$(INSTALL_DIR) $(1)/usr/share/dansguardian
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/dansguardian/transparent1x1.gif $(1)/usr/share/dansguardian/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/dansguardian/blockedflash.swf $(1)/usr/share/dansguardian/

	$(INSTALL_DIR) $(1)/usr/share/dansguardian/languages/ukenglish
	$(CP) $(PKG_INSTALL_DIR)/usr/share/dansguardian/languages/ukenglish/* $(1)/usr/share/dansguardian/languages/ukenglish/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/dansguardian.init $(1)/etc/init.d/dansguardian
endef

$(eval $(call BuildPackage,dansguardian))
