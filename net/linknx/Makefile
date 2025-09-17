#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=linknx
PKG_VERSION:=0.0.1.39
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-${PKG_VERSION}.tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/linknx/linknx/tar.gz/$(PKG_VERSION)?
PKG_HASH:=d07199875c6e3f90871308989dd7d4240b67ce971d5908cb39592690341f8d0a

PKG_MAINTAINER:=Othmar Truniger <github@truniger.ch>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=USE_UCLIBC:argp-standalone USE_MUSL:argp-standalone
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/linknx
  SECTION:=net
  CATEGORY:=Network
  TITLE:=KNX home automation platform
  URL:=https://github.com/linknx/linknx
  DEPENDS:=+pthsem +lua +luac +libcurl +libesmtp +libstdcpp $(ICONV_DEPENDS)
endef

CONFIGURE_ARGS+= \
	--verbose \
	--without-pth-test \
	--without-log4cpp \
	--with-lua \
	--with-libcurl \
	--without-jsoncpp \
	--without-cppunit \
	--without-mysql

define Package/linknx/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/linknx $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/linknx.init $(1)/etc/init.d/linknx
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/linknx.config $(1)/etc/config/linknx
	$(INSTALL_DATA) ./files/linknx.xml.dist $(1)/etc/linknx.xml.dist
	$(INSTALL_DIR) $(1)/tmp/linknx/persist
endef

define Package/linknx/conffiles
/etc/config/linknx
/etc/linknx.xml.dist
endef

$(eval $(call BuildPackage,linknx))
