#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=upmpdcli
PKG_VERSION:=1.1.3
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.lesbonscomptes.com/upmpdcli/downloads
PKG_HASH:=2df3e6593f18c097b6247fb8da919b94701bf083b219056b006d68e6dcef75b5
PKG_MAINTAINER:=Petko Bordjukov <bordjukov@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/upmpdcli
  SECTION:=sound
  CATEGORY:=Sound
  URL:=http://www.lesbonscomptes.com/upmpdcli
  DEPENDS+= +libupnpp +libmpdclient
  TITLE:=A UPnP front-end to MPD, the Music Player Daemon
  USERID:=upmpdcli=89:upmpdcli=89
  MENU:=1
endef

define Package/upmpdcli/description
upmpdcli implements an UPnP Media Renderer, using MPD to perform the real work.
endef

define Package/upmpdcli/config
	source "$(SOURCE)/Config.in"
endef

define Package/upmpdcli/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/upmpdcli.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/upmpdcli.config $(1)/etc/config/upmpdcli
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/upmpdcli $(1)/usr/bin/
ifeq ($(CONFIG_PACKAGE_UPMPDCLI_SCCTL),y)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/scctl $(1)/usr/bin/
endif
	$(INSTALL_DIR) $(1)/usr/share/upmpdcli
ifneq ($(CONFIG_PACKAGE_UPMPDCLI_SC_WEB_INTERFACE),y)
	$(RM) -rf $(PKG_INSTALL_DIR)/usr/share/upmpdcli/web
endif
	$(CP) $(PKG_INSTALL_DIR)/usr/share/upmpdcli $(1)/usr/share/
	$(INSTALL_DATA) ./files/upmpdcli.png $(1)/usr/share/upmpdcli/icon.png
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/upmpdcli.init $(1)/etc/init.d/upmpdcli
endef

$(eval $(call BuildPackage,upmpdcli))
