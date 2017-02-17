#
# Copyright (C) 2016 Toke Høiland-Jørgensen
#
# This is free software, licensed under the GNU General Public License v3 or
# later.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acme
PKG_SOURCE_VERSION:=6d84da588b98733dd9c4f5b88440281ab1eb4989
PKG_VERSION:=1.4
PKG_RELEASE:=2
PKG_LICENSE:=GPLv3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE).tar.xz
PKG_SOURCE_URL:=git://github.com/Neilpang/acme.sh.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)

include $(INCLUDE_DIR)/package.mk

define Package/acme
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+curl +ca-certificates +openssl-util +netcat
  TITLE:=ACME (Letsencrypt) client
  PKGARCH:=all
  MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
endef

define Package/acme/description
 A client for issuing Letsencrypt certificates.
endef

define Package/acme/conffiles
/etc/config/acme
/etc/acme
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/acme/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/acme.config $(1)/etc/config/acme
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/acme.init $(1)/etc/init.d/acme
	$(INSTALL_DIR) $(1)/usr/lib/acme
	$(INSTALL_BIN) ./files/run.sh $(1)/usr/lib/acme/run-acme
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/acme.sh $(1)/usr/lib/acme/acme.sh
endef


$(eval $(call BuildPackage,acme))
