#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pptpd
PKG_VERSION:=1.4.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/poptop
PKG_MD5SUM:=36f9f45c6ffa92bc3b6e24ae2d053505

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_MAINTAINER:=Luka Perkov <luka@openwrt.org>

include $(INCLUDE_DIR)/package.mk

define Package/pptpd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+kmod-ppp +kmod-gre +kmod-mppe +ppp
  TITLE:=PopTop pptp server
  URL:=http://poptop.sourceforge.net/
  SUBMENU:=VPN
endef

CONFIGURE_ARGS += \
	--enable-bcrelay \

CONFIGURE_VARS += \
	ac_cv_header_libintl_h=no \

MAKE_FLAGS += \
	COPTS="$(TARGET_CFLAGS)" \
	INSTALL="install" \

define Package/pptpd/conffiles
/etc/pptpd.conf
/etc/ppp/options.pptpd
/etc/config/pptpd
endef

define Package/pptpd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/sbin/bcrelay \
		$(PKG_INSTALL_DIR)/usr/sbin/pptpctrl \
		$(PKG_INSTALL_DIR)/usr/sbin/pptpd \
		$(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/lib/pptpd
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pptpd/* $(1)/usr/lib/pptpd/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/pptpd.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/pptpd.init $(1)/etc/init.d/pptpd
	$(INSTALL_DIR) $(1)/etc/ppp
	$(INSTALL_DATA) ./files/options.pptpd $(1)/etc/ppp/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/pptpd.config $(1)/etc/config/pptpd
endef

$(eval $(call BuildPackage,pptpd))
