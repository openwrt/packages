#
# Copyright (C) 2017  Sven Eckelmann <sven@narfation.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ratechecker
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://bitbucket.org/comnets/ratechecker.git
PKG_SOURCE_DATE:=2020-01-30
PKG_SOURCE_VERSION:=a2b8b958548bacdb69ffac3aa033f519093415f7
PKG_MIRROR_HASH:=b5b73d1d2c8c9a0b9e6974c945268d1d77d6380e7d49cb85eb4fa8db07a076d8

PKG_MAINTAINER:=Simon Wunderlich <sw@simonwunderlich.de>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ratechecker
  SECTION:=net
  CATEGORY:=Network
  TITLE:=IEEE 802.11 bitrate analysis tool
  URL:=https://bitbucket.org/comnets/ratechecker/
  DEPENDS:=+libevent2
endef

define Package/ratechecker/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/tmp/ratechecker $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,ratechecker))
