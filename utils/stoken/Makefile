#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=stoken
PKG_VERSION:=0.8
PKG_REV:=c4d79ffbf5053e44be4b64da22b1b7fb6a51daf2
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/cernekee/stoken.git

PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_REV).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_MAINTAINER:=Florian Fainelli <florian@openwrt.org>
PKG_LICENSE:=LGPL-2.1
PKG_INSTALL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/stoken/Default
  TITLE:=stoken is a tokencode generator compatible with RSA SecurID 128-bit (AES)
  URL:=http://sourceforge.net/p/stoken/
  DEPENDS:= +libxml2 +libnettle
endef

define Package/stoken
  $(call Package/stoken/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Encryption
  DEPENDS:=+libstoken
  MENU:=1
endef

define Package/stoken/description
  stoken is a tokencode generator compatible with RSA SecurID 128-bit (AES). This package contains the cli
endef

define Package/libstoken
  $(call Package/stoken/Default)
  SECTION:=libs
  CATEGORY:=Libraries
endef

CONFIGURE_ARGS += \
	--with-nettle

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libstoken*.{la,a,so*} $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/stoken.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/stoken/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/stoken $(1)/usr/bin/
endef

define Package/libstoken/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libstoken*.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,stoken))
$(eval $(call BuildPackage,libstoken))
