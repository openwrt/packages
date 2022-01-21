# SPDX-License-Identifier: MIT
#
# Copyright (C) 2021-2022 Gerald Kerma
#

include $(TOPDIR)/rules.mk

PKG_NAME:=crowdsec-nginx-bouncer
PKG_VERSION:=0.0.7
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/crowdsecurity/cs-nginx-bouncer/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=489a269c65ebf477810826f6115a5fd63a3c14b72d5bcc8b4854b24f8c38b329
PKG_BUILD_DIR:=$(BUILD_DIR)/cs-nginx-bouncer-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Gerald Kerma <gandalf@gk2.net>

include $(INCLUDE_DIR)/package.mk

define Package/crowdsec-nginx-bouncer
  SECTION:=net
  CATEGORY:=Network
  TITLE:=nginx bouncer for Crowdsec
  URL:=https://github.com/crowdsecurity/crowdsec-nginx-bouncer/
  DEPENDS:=+lua \
        +lua-cs-bouncer
endef

define Package/crowdsec-nginx-bouncer/description
  Crowdsec bouncer is a lua bouncer for nginx.

  New/unknown IP are checked against crowdsec API, and if request
  should be blocked, a 403 is returned to the user, and put in cache.
endef

define Build/Compile
endef

define Package/crowdsec-nginx-bouncer/install
	$(INSTALL_DIR) $(1)/etc/crowdsec/bouncers
	$(INSTALL_DATA) \
	        $(PKG_BUILD_DIR)/config/crowdsec.conf \
	        $(1)/etc/crowdsec/bouncers/crowdsec-nginx-bouncer.conf

	$(INSTALL_DIR) $(1)/etc/nginx/conf.d
	$(INSTALL_DATA) \
	        $(PKG_BUILD_DIR)/nginx/crowdsec_nginx.conf \
	        $(1)/etc/nginx/conf.d/

	$(INSTALL_DIR) $(1)/usr/lib/lua/crowdsec
	$(INSTALL_DATA) \
	        $(PKG_BUILD_DIR)/nginx/access.lua \
	        $(1)/usr/lib/lua/crowdsec/

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) \
		./files/crowdsec-nginx-bouncer.defaults \
		$(1)/etc/uci-defaults/99_crowdsec-nginx-bouncer
endef

define Package/crowdsec-nginx-bouncer/conffiles
/etc/crowdsec/bouncers/crowdsec-nginx-bouncer.conf
endef

$(eval $(call BuildPackage,crowdsec-nginx-bouncer))
