#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=upmpdcli
PKG_VERSION:=0.9.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.lesbonscomptes.com/upmpdcli/downloads
PKG_MD5SUM:=0e7b86037f19ea3a08067409af6f6902
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
endef

define Package/upmpdcli/description
upmpdcli implements an UPnP Media Renderer, using MPD to perform the real work.
endef

define Package/upmpdcli/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/upmpdcli.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/upmpdcli.config $(1)/etc/config/upmpdcli
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/upmpdcli $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share/upmpdcli
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/upmpdcli/* $(1)/usr/share/upmpdcli/
	$(INSTALL_DATA) ./files/upmpdcli.png $(1)/usr/share/upmpdcli/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/upmpdcli.init $(1)/etc/init.d/upmpdcli
endef

$(eval $(call BuildPackage,upmpdcli))
