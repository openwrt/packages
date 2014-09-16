#
# Copyright (C) 2011 segal.ubi.pt
# Copyright (C) 2010-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ntripclient
PKG_VERSION:=1.5.0
PKG_RELEASE:=2
PKG_LICENSE:=GPL-2.0+

PKG_SOURCE:=$(PKG_NAME).zip
PKG_SOURCE_URL:=http://igs.bkg.bund.de/root_ftp/NTRIP/software/
PKG_MD5SUM:=4b357fa648d74e4e13c4b5a2a39f5624

PKG_MAINTAINER:=Nuno Goncalves <nunojpg@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/ntripclient
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=NTRIP
  TITLE:=Ntrip Version 2.0 Command Line Client
  URL:=http://igs.bkg.bund.de/ntrip/download
endef

define Package/ntripclient/description
  Ntrip Version 2.0 Command Line Client, reading from Ntrip Version 1.0 or 2.0 Caster
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	unzip $(DL_DIR)/$(PKG_SOURCE) -d $(PKG_BUILD_DIR)
endef

MAKE_FLAGS += \
	OPTS="$(TARGET_CFLAGS)"

define Package/ntripclient/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ntripclient $(1)/usr/bin/
endef

$(eval $(call BuildPackage,ntripclient))
