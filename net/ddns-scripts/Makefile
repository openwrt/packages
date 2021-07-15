#
# Copyright (C) 2008-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-scripts
PKG_VERSION:=2.8.2
PKG_RELEASE:=11

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
  DEPENDS:=+ddns-scripts-services
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


define Package/ddns-scripts-services
  $(call Package/ddns-scripts/Default)
  TITLE:=Common ddns providers
endef

define Package/ddns-scripts-services/description
  Dynamic DNS Client definitions for supported services
endef


define Package/ddns-scripts-cloudflare
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for cloudflare.com API v4
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts-cloudflare/description
  Dynamic DNS Client scripts extension for cloudflare.com API v4 (require curl)
endef


define Package/ddns-scripts-freedns
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for freedns.42.pl
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts-freedns/description
  Dynamic DNS Client scripts extension for "freedns.42.pl".
endef


define Package/ddns-scripts-godaddy
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for godaddy.com API v1
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts-godaddy/description
  Dynamic DNS Client scripts extension for "godaddy.com API v1".
endef


define Package/ddns-scripts-digitalocean
  $(call Package/ddns-scripts/Default)
  TITLE:=Extention for digitalocean.com API v2
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts-digitalocean/description
  Dynamic DNS Client scripts extension for "digitalocean.com API v2".
  The script directly updates a DNS record using the DO API.
  It requires:
  "option dns_server" to be set to the server to be used by nsupdate.
  "option domain" the dns domain to update the record for (eg. A-record: home.<example.com>)
  "option username" the dns record name to update (eg. A-record: <home>.example.com)
  "option param_opt" the id of the dns record to update (check using chrome inspector in the DO dns tab)
  "option password" the api token generated in the DO panel
endef


define Package/ddns-scripts-noip
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for no-ip.com
  DEPENDS:=ddns-scripts
endef

define Package/ddns-scripts-noip/description
  Dynamic DNS Client scripts extension for "no-ip.com".
endef


define Package/ddns-scripts-nsupdate
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for using bind nsupdate.
  DEPENDS:=ddns-scripts +bind-client
endef

define Package/ddns-scripts-nsupdate/description
  Dynamic DNS Client scripts extension for direct updates using bind nsupdate
  The script directly updates a PowerDNS (or maybe bind server) via nsupdate
  from bind-client package.
  It requires:
  "option dns_server" to be set to the server to be used by nsupdate.
  "option username" should be set to the key name and
  "option password" to the base64 encoded shared secret.
endef


define Package/ddns-scripts-route53
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for route53 API v1
  DEPENDS:=ddns-scripts +curl +openssl-util
endef

define Package/ddns-scripts-route53/description
  Dynamic DNS Client scripts extension for Amazon AWS "route53 API v1".
  Note: You must also install ca-certificate or ca-bundle.
  It requires:
  "option username" to be a valid AWS access key id
  "option password" to be the matching AWS secret key id
  "option domain" to contain the hosted zone ID
endef


define Package/ddns-scripts-cnkuai
  $(call Package/ddns-scripts/Default)
  TITLE:=CnKuai API
  DEPENDS:=ddns-scripts +curl +giflib-utils
endef

define Package/ddns-scripts-cnkuai/description
  Dynamic DNS Client scripts extension for "cnkuai.cn".
  It requires:
  "option username" to be a valid CnKuai control panel id
  "option password" to be the matching CnKuai control panel password
  "option domain" to contain the domain
endef


define Package/ddns-scripts-gandi
  $(call Package/ddns-scripts/Default)
  TITLE:=Gandi API
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts-gandi/description
  Dynamic DNS Client scripts extension for "gandi.net".
  It requires:
  "option username" to be a valid subdomain for gandi.net
  "option password" to be a valid API key for ganid.net
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


define Package/ddns-scripts-services/install
	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/* \
		$(1)/usr/share/ddns/default

	# Remove special services
	rm $(1)/usr/share/ddns/default/cloudflare.com-v4.json
	rm $(1)/usr/share/ddns/default/freedns.42.pl.json
	rm $(1)/usr/share/ddns/default/godaddy.com-v1.json
	rm $(1)/usr/share/ddns/default/digitalocean.com-v2.json
	rm $(1)/usr/share/ddns/default/no-ip.com.json
	rm $(1)/usr/share/ddns/default/bind-nsupdate.json
	rm $(1)/usr/share/ddns/default/route53-v1.json
	rm $(1)/usr/share/ddns/default/cnkuai.cn.json
	rm $(1)/usr/share/ddns/default/gandi.net.json
endef


define Package/ddns-scripts-cloudflare/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_cloudflare_com_v4.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/cloudflare.com-v4.json \
		$(1)/usr/share/ddns/default/
endef

define Package/ddns-scripts-cloudflare/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-freedns/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_freedns_42_pl.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/freedns.42.pl.json \
		$(1)/usr/share/ddns/default
endef

define Package/ddns-scripts-freedns/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-godaddy/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_godaddy_com_v1.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/godaddy.com-v1.json \
		$(1)/usr/share/ddns/default
endef

define Package/ddns-scripts-godaddy/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-digitalocean/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_digitalocean_com_v2.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/digitalocean.com-v2.json \
		$(1)/usr/share/ddns/default
endef

define Package/ddns-scripts-digitalocean/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-noip/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_no-ip_com.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/no-ip.com.json \
		$(1)/usr/share/ddns/default
endef

define Package/ddns-scripts-noip/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-nsupdate/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_nsupdate.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/bind-nsupdate.json \
		$(1)/usr/share/ddns/default
endef

define Package/ddns-scripts-nsupdate/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-route53/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_route53_v1.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/route53-v1.json \
		$(1)/usr/share/ddns/default
endef

define Package/ddns-scripts-route53/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-cnkuai/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_cnkuai_cn.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/cnkuai.cn.json \
		$(1)/usr/share/ddns/default
endef

define Package/ddns-scripts-cnkuai/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-gandi/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_gandi_net.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/gandi.net.json \
		$(1)/usr/share/ddns/default
endef

define Package/ddns-scripts-gandi/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


$(eval $(call BuildPackage,ddns-scripts))
$(eval $(call BuildPackage,ddns-scripts-services))
$(eval $(call BuildPackage,ddns-scripts-cloudflare))
$(eval $(call BuildPackage,ddns-scripts-freedns))
$(eval $(call BuildPackage,ddns-scripts-godaddy))
$(eval $(call BuildPackage,ddns-scripts-digitalocean))
$(eval $(call BuildPackage,ddns-scripts-noip))
$(eval $(call BuildPackage,ddns-scripts-nsupdate))
$(eval $(call BuildPackage,ddns-scripts-route53))
$(eval $(call BuildPackage,ddns-scripts-cnkuai))
$(eval $(call BuildPackage,ddns-scripts-gandi))
