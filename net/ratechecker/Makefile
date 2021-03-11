#
# Copyright (C) 2017  Sven Eckelmann <sven@narfation.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ratechecker
PKG_VERSION:=0.0.20170609
PKG_RELEASE:=2
PKG_REV:=4cd4e3c70d9832336af5ba157f2a272f9c0098dc
PKG_MIRROR_HASH:=c6f02b273536738bbcf4b16e3859f733a02ada88b4078fc8a5b0ad8d1d184370

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_URL:=https://bitbucket.org/comnets/ratechecker.git
PKG_SOURCE_PROTO:=git

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ratechecker
  SECTION:=net
  CATEGORY:=Network
  TITLE:=IEEE 802.11 bitrate analysis tool
  URL:=https://bitbucket.org/comnets/ratechecker/
  DEPENDS:=+libevent2
  MAINTAINER:=Simon Wunderlich <sw@simonwunderlich.de>
endef

define Package/ratechecker/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/tmp/ratechecker $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,ratechecker))
