# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.

include $(TOPDIR)/rules.mk

PKG_NAME:=babel-pinger
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.pps.univ-paris-diderot.fr/~jch/software/files/
PKG_MD5SUM:=40d4931986913f5f8d9b5b70abf6fda5

include $(INCLUDE_DIR)/package.mk

define Package/babel-pinger
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=Babel-pinger
  URL:=http://www.pps.univ-paris-diderot.fr/~jch/software/babel/
  MAINTAINER:=Gabriel Kerneis <gabriel@kerneis.info>
  DEPENDS:=+librt
endef

define Package/babel-pinger/description
 Babel-pinger is a hack to export a default route into Babel for people
 using DHCP to configure their routers rather than speaking to their
 upstream provider with a proper routing protocol.
endef

MAKE_FLAGS+= \
	CFLAGS="$(TARGET_CFLAGS)" \

define Package/babel-pinger/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/babel-pinger $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,babel-pinger))
