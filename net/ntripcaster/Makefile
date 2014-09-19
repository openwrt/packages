#
# Copyright (C) 2011 segal.ubi.pt
# Copyright (C) 2010-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ntripcaster
PKG_VERSION:=0.1.5
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0+

PKG_SOURCE:=$(PKG_NAME)$(PKG_VERSION).zip
PKG_SOURCE_URL:=http://igs.bkg.bund.de/root_ftp/NTRIP/software/
PKG_MD5SUM:=8c85a6c31d8c5cdf2638fe103207a1fd

PKG_MAINTAINER:=Nuno Goncalves <nunojpg@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/ntripcaster
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=NTRIP
  TITLE:=Standard Ntrip Broadcaster
  URL:=http://igs.bkg.bund.de/ntrip/download
  DEPENDS:=+libpthread
endef

define Package/ntripcaster/description
  BKG Standard Ntrip Broadcaster
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	unzip $(DL_DIR)/$(PKG_SOURCE) -d $(PKG_BUILD_DIR)
	mv $(PKG_BUILD_DIR)/$(PKG_NAME)$(PKG_VERSION)/* $(PKG_BUILD_DIR)
	chmod +x $(PKG_BUILD_DIR)/configure
endef

define Package/ntripcaster/install
	$(INSTALL_DIR) $(1)/usr/local/ntripcaster/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ntripcaster $(1)/usr/local/ntripcaster/bin/
	$(INSTALL_DIR) $(1)/usr/local/ntripcaster/conf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/conf/ntripcaster.conf.dist $(1)/usr/local/ntripcaster/conf/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/conf/sourcetable.dat.dist $(1)/usr/local/ntripcaster/conf/
endef

$(eval $(call BuildPackage,ntripcaster))
