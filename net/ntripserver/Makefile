#
# Copyright (C) 2011 segal.ubi.pt
# Copyright (C) 2010-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ntripserver
PKG_VERSION:=1.5.1
PKG_RELEASE:=2
PKG_LICENSE:=GPL-2.0+

PKG_SOURCE:=$(PKG_NAME).zip
PKG_SOURCE_URL:=http://igs.bkg.bund.de/root_ftp/NTRIP/software/
PKG_MD5SUM:=cecff5da0173896df041bd889935fc12

PKG_MAINTAINER:=Nuno Goncalves <nunojpg@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/ntripserver
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=NTRIP
  TITLE:=Ntrip Version 2.0 Command Line Server
  URL:=http://igs.bkg.bund.de/ntrip/download
endef

define Package/ntripserver/description
  Ntrip Version 2.0 Command Line Server, reading from SISNeT Server, TCP/UDP IP Port, Serial port, or NtripCaster to support an Ntrip Version 1.0 or 2.0 Caster
endef

MAKE_FLAGS += \
	OPTS="$(TARGET_CFLAGS)"

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	unzip $(DL_DIR)/$(PKG_SOURCE) -d $(PKG_BUILD_DIR)
endef

define Package/ntripserver/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ntripserver $(1)/usr/bin/
endef

$(eval $(call BuildPackage,ntripserver))
