# SPDX-License-Identifier: GPL-2.0-or-later
#
# Copyright (C) 2022 - 2026 BlueWave Projects and Services  <licence@blue-wave.net>
#


include $(TOPDIR)/rules.mk

PKG_NAME:=opennds
PKG_VERSION:=11.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/openNDS/openNDS/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b7510987c79f4fbd21f514edd9d74b15fab7b0bc08529529408389d48fa39be9
PKG_BUILD_DIR:=$(BUILD_DIR)/openNDS-$(PKG_VERSION)

PKG_MAINTAINER:=Rob White <rob@blue-wave.net>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:opennds:captive_portal

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/opennds
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libmicrohttpd-no-ssl
  TITLE:=open Network Demarcation Service
  URL:=https://github.com/openNDS/openNDS
  CONFLICTS:=nodogsplash
endef

define Package/opennds/description
  OpenNDS (open Network Demarcation Service).
  A high performance border control gateway.
  Operates between a public local area network and the Internet.
  User interaction is via a Captive Portal splash page sequence.
  Fair usage policies can be enforced globally or at user level.
  Operates stand alone or with multiple portal entry points.
  Traditional client driven Captive Portal Detection (CPD)
  and gateway driven Captive Portal Identification (CPI)
  (RFC 8910 and RFC 8908) are supported.
endef

define Package/opennds/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/opennds/htdocs/images
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/lib/opennds
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/linux_openwrt/opennds/files/etc/config/opennds $(1)/etc/config/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/opennds $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ndsctl $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/libs/ndscfg $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/linux_openwrt/opennds/files/etc/init.d/opennds $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/linux_openwrt/opennds/files/usr/lib/opennds/restart.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/linux_openwrt/opennds/files/usr/lib/opennds/fw_include.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/binauth/binauth_log.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/binauth/custombinauth.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/binauth/check_reauth_interval.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/libs/libopennds.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/PreAuth/theme_click-to-continue-basic.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/PreAuth/theme_click-to-continue-custom-placeholders.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/PreAuth/theme_user-email-login-basic.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/PreAuth/theme_user-email-login-custom-placeholders.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/PreAuth/theme_trusted_only.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/PreAuth/theme_allow_all.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/libs/get_client_interface.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/libs/client_params.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/libs/authmon.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/libs/dnsconfig.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/libs/download_resources.sh $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/libs/post-request.php $(1)/usr/lib/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/fas-aes/fas-aes.php $(1)/etc/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/fas-hid/fas-hid.php $(1)/etc/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/fas-hid/fas-hid-https.php $(1)/etc/opennds/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/forward_authentication_service/fas-aes/fas-aes-https.php $(1)/etc/opennds/
	$(CP) $(PKG_BUILD_DIR)/resources/splash.css $(1)/etc/opennds/htdocs/
	$(CP) $(PKG_BUILD_DIR)/resources/splash.jpg $(1)/etc/opennds/htdocs/images/

endef

define Package/opennds/prerm
#!/bin/sh
# Remove the firewall include without committing other staged firewall changes.
if [ -z "$${IPKG_INSTROOT}" ]; then
	/usr/lib/opennds/fw_include.sh remove
fi
endef

define Package/opennds/conffiles
/etc/config/opennds
/etc/opennds/htdocs/splash.css
/etc/opennds/htdocs/images/splash.jpg
endef

$(eval $(call BuildPackage,opennds))
