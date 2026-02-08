# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021-2022 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=v2ray-geodata
PKG_RELEASE:=1

PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

include $(INCLUDE_DIR)/package.mk

GEOIP_VER:=202602050222
GEOIP_FILE:=geoip.dat.$(GEOIP_VER)
define Download/geoip
  URL:=https://github.com/v2fly/geoip/releases/download/$(GEOIP_VER)/
  URL_FILE:=geoip.dat
  FILE:=$(GEOIP_FILE)
  HASH:=838ab094bc01b9bafc849ce70c6f439dcb158d0c0dd41441ddb3c38d4d9ef563
endef

GEOSITE_VER:=20260208055239
GEOSITE_FILE:=dlc.dat.$(GEOSITE_VER)
define Download/geosite
  URL:=https://github.com/v2fly/domain-list-community/releases/download/$(GEOSITE_VER)/
  URL_FILE:=dlc.dat
  FILE:=$(GEOSITE_FILE)
  HASH:=d16eeb384577aa723ca59bcd4c23b68ceec76623dbc751fe38a8014207cfa390
endef

GEOSITE_IRAN_VER:=202602061019
GEOSITE_IRAN_FILE:=iran.dat.$(GEOSITE_IRAN_VER)
define Download/geosite-ir
  URL:=https://github.com/bootmortis/iran-hosted-domains/releases/download/$(GEOSITE_IRAN_VER)/
  URL_FILE:=iran.dat
  FILE:=$(GEOSITE_IRAN_FILE)
  HASH:=101d6a57d6c315c422916dd85b17aeec7d4ed9302f742154fe07b24d1a0ec1c6
endef

define Package/v2ray-geodata/template
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  URL:=https://www.v2fly.org
  PKGARCH:=all
endef

define Package/v2ray-geoip
  $(call Package/v2ray-geodata/template)
  TITLE:=GeoIP List for V2Ray
  PROVIDES:=v2ray-geodata xray-geodata xray-geoip
  VERSION:=$(GEOIP_VER)-r$(PKG_RELEASE)
  LICENSE:=CC-BY-SA-4.0
endef

define Package/v2ray-geosite
  $(call Package/v2ray-geodata/template)
  TITLE:=Geosite List for V2Ray
  PROVIDES:=v2ray-geodata xray-geodata xray-geosite
  VERSION:=$(GEOSITE_VER)-r$(PKG_RELEASE)
  LICENSE:=MIT
endef

define Package/v2ray-geosite-ir
  $(call Package/v2ray-geodata/template)
  TITLE:=Iran Geosite List for V2Ray
  PROVIDES:=xray-geosite-ir
  VERSION:=$(GEOSITE_IRAN_VER)-r$(PKG_RELEASE)
  LICENSE:=MIT
endef

define Build/Prepare
	$(call Build/Prepare/Default)
ifneq ($(CONFIG_PACKAGE_v2ray-geoip),)
	$(call Download,geoip)
endif
ifneq ($(CONFIG_PACKAGE_v2ray-geosite),)
	$(call Download,geosite)
endif
ifneq ($(CONFIG_PACKAGE_v2ray-geosite-ir),)
	$(call Download,geosite-ir)
endif
endef

define Build/Compile
endef

define Package/v2ray-geoip/install
	$(INSTALL_DIR) $(1)/usr/share/v2ray $(1)/usr/share/xray
	$(INSTALL_DATA) $(DL_DIR)/$(GEOIP_FILE) $(1)/usr/share/v2ray/geoip.dat
	$(LN) ../v2ray/geoip.dat $(1)/usr/share/xray/geoip.dat
endef

define Package/v2ray-geosite/install
	$(INSTALL_DIR) $(1)/usr/share/v2ray $(1)/usr/share/xray
	$(INSTALL_DATA) $(DL_DIR)/$(GEOSITE_FILE) $(1)/usr/share/v2ray/geosite.dat
	$(LN) ../v2ray/geosite.dat $(1)/usr/share/xray/geosite.dat
endef

define Package/v2ray-geosite-ir/install
	$(INSTALL_DIR) $(1)/usr/share/v2ray $(1)/usr/share/xray
	$(INSTALL_DATA) $(DL_DIR)/$(GEOSITE_IRAN_FILE) $(1)/usr/share/v2ray/iran.dat
	$(LN) ../v2ray/iran.dat $(1)/usr/share/xray/iran.dat
endef

$(eval $(call BuildPackage,v2ray-geoip))
$(eval $(call BuildPackage,v2ray-geosite))
$(eval $(call BuildPackage,v2ray-geosite-ir))
