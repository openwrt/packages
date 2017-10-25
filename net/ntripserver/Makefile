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

PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/nunojpg/ntripserver.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=c3034ab575e8442222eb8c2ee9e224cac99cfa6d
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=71f168c4b41c9e1063280fc8aa21d8794c064708fbfa4929093ef5a139e2e736

PKG_LICENSE:=GPL-2.0+

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
  Ntrip Version 2.0 Command Line Server, reading from SISNeT Server, TCP/UDP IP
  Port, Serial port, or NtripCaster to support an Ntrip Version 1.0 or 2.0 Caster
endef

MAKE_FLAGS += \
	OPTS="$(TARGET_CFLAGS)"

define Package/ntripserver/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ntripserver $(1)/usr/bin/
endef

$(eval $(call BuildPackage,ntripserver))
