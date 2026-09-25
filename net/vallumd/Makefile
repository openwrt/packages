#
# Copyright (C) 2017 Stijn Tintel <stijn@linux-ipv6.be>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vallumd
PKG_VERSION:=0.2.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeberg.org/stintel/vallumd/archive/$(PKG_VERSION).tar.gz?
PKG_HASH:=9e055668d955194158f9d8f12f96d5065e055aefb2ad3b87d433c5a837d2be39
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

PKG_MAINTAINER:=Stijn Tintel <stijn@linux-ipv6.be>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/vallumd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Centralized or distributed blacklist
  DEPENDS:=+ca-bundle +ipset +libmosquitto +libopenssl
endef

define Package/vallumd/description
  Centralized or distributed blacklist
endef

define Package/vallumd/conffiles
/etc/config/vallumd
endef

define Package/vallumd/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d $(1)/usr/sbin
	$(INSTALL_CONF) ./files/vallumd.conf $(1)/etc/config/vallumd
	$(INSTALL_BIN) ./files/vallumd.init $(1)/etc/init.d/vallumd
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/vallumd $(1)/usr/sbin/vallumd
endef


$(eval $(call BuildPackage,vallumd))
