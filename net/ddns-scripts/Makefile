#
# Copyright (C) 2008-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-scripts
PKG_VERSION:=2.8.0
PKG_RELEASE:=24

PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/ddns-scripts/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  PKGARCH:=all
endef


define Package/ddns-scripts
  $(call Package/ddns-scripts/Default)
  TITLE:=Dynamic DNS Client scripts (with IPv6 support)
endef

define Package/ddns-scripts/description
  Dynamic DNS Client scripts (with IPv6 support)
  A highly configurable set of scripts for doing dynamic dns updates.
  - IPv6 support
  - DNS server support
  - Glue Record support (require BIND host or KNOT host)
  - DNS requests via TCP
  - Proxy server support
  - log file support
  - support to run once
  Version: $(PKG_VERSION)-$(PKG_RELEASE)
  Info   : https://openwrt.org/docs/guide-user/services/ddns/client
endef

define Package/ddns-scripts/conffiles
/etc/config/ddns
endef


define Package/ddns-scripts_service
  $(call Package/ddns-scripts/Default)
  TITLE:=Common ddns providers
  DEPENDS:=ddns-scripts
endef

define Package/ddns-scripts_service/description
  Dynamic DNS Client definitions for supported services
endef


define Package/ddns-scripts_cloudflare.com-v4
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for cloudflare.com API v4
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts_cloudflare.com-v4/description
  Dynamic DNS Client scripts extension for cloudflare.com API v4 (require curl)
endef


define Package/ddns-scripts_freedns_42_pl
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for freedns.42.pl
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts_freedns_42_pl/description
  Dynamic DNS Client scripts extension for "freedns.42.pl".
endef


define Package/ddns-scripts_godaddy.com-v1
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for godaddy.com API v1
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts_godaddy.com-v1/description
  Dynamic DNS Client scripts extension for "godaddy.com API v1".
endef


define Package/ddns-scripts_digitalocean.com-v2
  $(call Package/ddns-scripts/Default)
  TITLE:=Extention for digitalocean.com API v2
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts_digitalocean.com-v2/description
  Dynamic DNS Client scripts extension for "digitalocean.com API v2".
  The script directly updates a DNS record using the DO API.
  It requires:
  "option dns_server" to be set to the server to be used by nsupdate.
  "option domain" the dns domain to update the record for (eg. A-record: home.<example.com>)
  "option username" the dns record name to update (eg. A-record: <home>.example.com)
  "option param_opt" the id of the dns record to update (check using chrome inspector in the DO dns tab)
  "option password" the api token generated in the DO panel
endef


define Package/ddns-scripts_no-ip_com
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for no-ip.com
  DEPENDS:=ddns-scripts
endef

define Package/ddns-scripts_no-ip_com/description
  Dynamic DNS Client scripts extension for "no-ip.com".
endef


define Package/ddns-scripts_nsupdate
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for using bind nsupdate.
  DEPENDS:=ddns-scripts +bind-client
endef

define Package/ddns-scripts_nsupdate/description
  Dynamic DNS Client scripts extension for direct updates using bind nsupdate
  The script directly updates a PowerDNS (or maybe bind server) via nsupdate
  from bind-client package.
  It requires:
  "option dns_server" to be set to the server to be used by nsupdate.
  "option username" should be set to the key name and
  "option password" to the base64 encoded shared secret.
endef


define Package/ddns-scripts_route53-v1
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for route53 API v1
  DEPENDS:=ddns-scripts +curl +openssl-util
endef

define Package/ddns-scripts_route53-v1/description
  Dynamic DNS Client scripts extension for Amazon AWS "route53 API v1".
  Note: You must also install ca-certificate or ca-bundle.
  It requires:
  "option username" to be a valid AWS access key id
  "option password" to be the matching AWS secret key id
  "option domain" to contain the hosted zone ID
endef


define Package/ddns-scripts_cnkuai_cn
  $(call Package/ddns-scripts/Default)
  TITLE:=CnKuai API
  DEPENDS:=ddns-scripts +curl +giflib-utils
endef

define Package/ddns-scripts_cnkuai_cn/description
  Dynamic DNS Client scripts extension for "cnkuai.cn".
  It requires:
  "option username" to be a valid CnKuai control panel id
  "option password" to be the matching CnKuai control panel password
  "option domain" to contain the domain
endef


define Build/Configure
endef

define Build/Compile
endef


define Package/ddns-scripts/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/etc/hotplug.d/iface/ddns \
		$(1)/etc/hotplug.d/iface/95-ddns

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/ddns \
		$(1)/etc/init.d/ddns

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/ddns \
		$(1)/etc/config/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns
	echo "$(PKG_VERSION)-$(PKG_RELEASE)" > $(1)/usr/share/ddns/version
	$(INSTALL_DATA) ./files/usr/share/ddns/list \
		$(1)/usr/share/ddns

	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_DATA) ./files/usr/lib/ddns/dynamic_dns_functions.sh \
		$(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/dynamic_dns_lucihelper.sh \
		$(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/dynamic_dns_updater.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/ddns.sh \
		$(1)/usr/bin/ddns
endef

define Package/ddns-scripts/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns enabled
	/etc/init.d/ddns start
fi
exit 0
endef

define Package/ddns-scripts/prerm
#!/bin/sh
if [ -n "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
	/etc/init.d/ddns disable
fi
exit 0
endef


define Package/ddns-scripts_service/install
	$(INSTALL_DIR) $(1)/usr/share/ddns/services
	$(INSTALL_DATA) ./files/usr/share/ddns/services/* \
		$(1)/usr/share/ddns/services
endef


define Package/ddns-scripts_cloudflare.com-v4/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_cloudflare_com_v4.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/services
	$(INSTALL_DATA) ./files/usr/share/ddns/services/cloudflare.com-v4.json \
		$(1)/usr/share/ddns/services/
endef

define Package/ddns-scripts_cloudflare.com-v4/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts_freedns_42_pl/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_freedns_42_pl.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/services
	$(INSTALL_DATA) ./files/usr/share/ddns/services/freedns.42.pl.json \
		$(1)/usr/share/ddns/services
endef

define Package/ddns-scripts_freedns_42_pl/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts_godaddy.com-v1/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_godaddy_com_v1.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/services
	$(INSTALL_DATA) ./files/usr/share/ddns/services/godaddy.com-v1.json \
		$(1)/usr/share/ddns/services
endef

define Package/ddns-scripts_godaddy.com-v1/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts_digitalocean.com-v2/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_digitalocean_com_v2.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/services
	$(INSTALL_DATA) ./files/usr/share/ddns/services/digitalocean.com-v2.json \
		$(1)/usr/share/ddns/services
endef

define Package/ddns-scripts_digitalocean.com-v2/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts_no-ip_com/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_no-ip_com.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/services
	$(INSTALL_DATA) ./files/usr/share/ddns/services/no-ip.com.json \
		$(1)/usr/share/ddns/services
endef

define Package/ddns-scripts_no-ip_com/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts_nsupdate/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_nsupdate.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/services
	$(INSTALL_DATA) ./files/usr/share/ddns/services/bind-nsupdate.json \
		$(1)/usr/share/ddns/services
endef

define Package/ddns-scripts_nsupdate/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts_route53-v1/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_route53_v1.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/services
	$(INSTALL_DATA) ./files/usr/share/ddns/services/route53-v1.json \
		$(1)/usr/share/ddns/services
endef

define Package/ddns-scripts_route53-v1/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts_cnkuai_cn/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_cnkuai_cn.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/services
	$(INSTALL_DATA) ./files/usr/share/ddns/services/cnkuai.cn.json \
		$(1)/usr/share/ddns/services
endef

define Package/ddns-scripts_cnkuai_cn/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


$(eval $(call BuildPackage,ddns-scripts))
$(eval $(call BuildPackage,ddns-scripts_service))
$(eval $(call BuildPackage,ddns-scripts_cloudflare.com-v4))
$(eval $(call BuildPackage,ddns-scripts_freedns_42_pl))
$(eval $(call BuildPackage,ddns-scripts_godaddy.com-v1))
$(eval $(call BuildPackage,ddns-scripts_digitalocean.com-v2))
$(eval $(call BuildPackage,ddns-scripts_no-ip_com))
$(eval $(call BuildPackage,ddns-scripts_nsupdate))
$(eval $(call BuildPackage,ddns-scripts_route53-v1))
$(eval $(call BuildPackage,ddns-scripts_cnkuai_cn))
