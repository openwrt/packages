#
# Copyright (C) 2011 segal.ubi.pt
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ntripclient
PKG_VERSION:=1.5.0

PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/nunojpg/ntripclient.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=dcfb2cb3e6f31b7291a94e7f86379c78ffc0d44e
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=8d16f2bd0295a2e77fe8651e5f973c3ca4cf0d62fc4d671ebb54cfa8dc7debd0

PKG_LICENSE:=GPL-2.0+

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

MAKE_FLAGS += \
	OPTS="$(TARGET_CFLAGS)"

define Package/ntripclient/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ntripclient $(1)/usr/bin/
endef

$(eval $(call BuildPackage,ntripclient))
