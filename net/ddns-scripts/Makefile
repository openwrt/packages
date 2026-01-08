#
# Copyright (C) 2008-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-scripts
PKG_VERSION:=2.8.2
PKG_RELEASE:=85

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
  DEPENDS:=+ddns-scripts-services +resolveip +ip
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
  PROVIDES:=ddns-scripts_service
endef

define Package/ddns-scripts-services/description
  Dynamic DNS Client definitions for supported services
endef

define Package/ddns-scripts-utils
  $(call Package/ddns-scripts/Default)
  TITLE:=Utility scripts for ddns configs
  DEPENDS:=ddns-scripts
endef

define Package/ddns-scripts-utils/description
  Dynamic DNS Client utility scripts for config files
endef


define Package/ddns-scripts-luadns
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for LuaDNS API v1
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts-luadns/description
  Dynamic DNS Client scripts extension for LuaDNS API v1 (require curl)
endef

define Package/ddns-scripts-cloudflare
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for cloudflare.com API v4
  DEPENDS:=ddns-scripts +curl
  PROVIDES:=ddns-scripts_cloudflare.com-v4
endef

define Package/ddns-scripts-cloudflare/description
  Dynamic DNS Client scripts extension for cloudflare.com API v4 (require curl)
endef


define Package/ddns-scripts-gcp
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for Google Cloud DNS API v1
  DEPENDS:=ddns-scripts +curl +openssl-util
endef

define Package/ddns-scripts-gcp/description
  Dynamic DNS Client scripts extension for Google Cloud DNS API v1 (requires curl)
endef


define Package/ddns-scripts-freedns
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for freedns.42.pl
  DEPENDS:=ddns-scripts +curl
  PROVIDES:=ddns-scripts_freedns_42_pl
endef

define Package/ddns-scripts-freedns/description
  Dynamic DNS Client scripts extension for 'freedns.42.pl'.
endef


define Package/ddns-scripts-godaddy
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for godaddy.com API v1
  DEPENDS:=ddns-scripts +curl
  PROVIDES:=ddns-scripts_godaddy.com-v1
endef

define Package/ddns-scripts-godaddy/description
  Dynamic DNS Client scripts extension for 'godaddy.com API v1'.
endef


define Package/ddns-scripts-digitalocean
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for digitalocean.com API v2
  DEPENDS:=ddns-scripts +curl
  PROVIDES:=ddns-scripts_digitalocean.com-v2
endef

define Package/ddns-scripts-digitalocean/description
  Dynamic DNS Client scripts extension for digitalocean.com API v2.
  The script directly updates a DNS record using the DO API.
  It requires:
  'option dns_server' to be set to the server to be used by nsupdate.
  'option domain' the dns domain to update the record for (eg. A-record: home.<example.com>)
  'option username' the dns record name to update (eg. A-record: <home>.example.com)
  'option param_opt' the id of the dns record to update (check using chrome inspector in the DO dns tab)
  'option password' the api token generated in the DO panel
endef

define Package/ddns-scripts-dnspod
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for dnspod.cn API
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts-dnspod/description
  Dynamic DNS Client scripts extension for dnspod.cn API (require curl)
endef


define Package/ddns-scripts-dnspod-v3
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for dnspod.tencentcloudapi.com (aka: dnspod.cn) API v3
  DEPENDS:=ddns-scripts +curl +openssl-util
endef

define Package/ddns-scripts-dnspod-v3/description
  Dynamic DNS Client scripts extension for dnspod.tencentcloudapi.com API v3 (require curl)
endef


define Package/ddns-scripts-noip
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for no-ip.com
  DEPENDS:=ddns-scripts
  PROVIDES:=ddns-scripts_no-ip_com
endef

define Package/ddns-scripts-noip/description
  Dynamic DNS Client scripts extension for 'no-ip.com'.
endef

define Package/ddns-scripts-ns1
  $(call Package/ddns-scripts/Default)
  TITLE:=NS1 API
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts-ns1/description
  Dynamic DNS Client scripts extension for 'ns1.com'.
  It requires:
  'option username' to be a valid zone for ns1.com
  'option password' to be a valid API key for ns1.com
endef


define Package/ddns-scripts-nsupdate
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for using bind nsupdate.
  DEPENDS:=ddns-scripts +bind-client
  PROVIDES:=ddns-scripts_nsupdate
endef

define Package/ddns-scripts-nsupdate/description
  Dynamic DNS Client scripts extension for direct updates using bind nsupdate
  The script directly updates a PowerDNS (or maybe bind server) via nsupdate
  from bind-client package.
  It requires:
  'option dns_server' to be set to the server to be used by nsupdate.
  'option username' should be set to the key name and
  'option password' to the base64 encoded shared secret.
endef


define Package/ddns-scripts-route53
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for route53 API v1
  DEPENDS:=ddns-scripts +curl +openssl-util
  PROVIDES:=ddns-scripts_route53-v1
endef

define Package/ddns-scripts-route53/description
  Dynamic DNS Client scripts extension for Amazon AWS 'route53 API v1'.
  Note: You must also install ca-certificate or ca-bundle.
  It requires:
  'option username' to be a valid AWS access key id
  'option password' to be the matching AWS secret key id
  'option domain' to contain the hosted zone ID
endef


define Package/ddns-scripts-cnkuai
  $(call Package/ddns-scripts/Default)
  TITLE:=CnKuai API
  DEPENDS:=ddns-scripts +curl +giflib-utils
  PROVIDES:=ddns-scripts_cnkuai_cn
endef

define Package/ddns-scripts-cnkuai/description
  Dynamic DNS Client scripts extension for 'cnkuai.cn'.
  It requires:
  'option username' to be a valid CnKuai control panel id
  'option password' to be the matching CnKuai control panel password
  'option domain' to contain the domain
endef


define Package/ddns-scripts-gandi
  $(call Package/ddns-scripts/Default)
  TITLE:=Gandi API
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts-gandi/description
  Dynamic DNS Client scripts extension for 'gandi.net'.
  It requires:
  'option username' to be a valid subdomain for gandi.net
  'option password' to be a valid API key for gandi.net
endef


define Package/ddns-scripts-beget
  $(call Package/ddns-scripts/Default)
  TITLE:=Beget API
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts-beget/description
  Dynamic DNS Client scripts extension for 'beget.com'.
  It requires:
  'option domain' to contain the domain
  'option username' to be a valid username for beget.com
  'option password' to be a valid API key for beget.com
endef


define Package/ddns-scripts-pdns
  $(call Package/ddns-scripts/Default)
  TITLE:=PowerDNS API
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts-pdns/description
  Dynamic DNS Client scripts extension for 'PowerDNS' via API.
  It requires:
  'option param_opt(Optional Parameter)' to be a valid root URL for the PowerDNS webserver
  'option username' to be a valid subdomain for the PowerDNS domain
  'option password' to be a valid API key for the PowerDNS webserver
endef

define Package/ddns-scripts-scaleway
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for Scaleway DNS API
  DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts-scaleway/description
  Dynamic DNS Client scripts extension for Scaleway.
  Parameters:
  'option username'  The zone in which the RR is to be set
  'option password'  The Scaleway API token with sufficient access rights
  'option domain'    The domain to be updated
  'option param_opt' (Optional) The TTL of the RR
endef

define Package/ddns-scripts-transip
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for TransIP API
  DEPENDS:=ddns-scripts +curl +openssl-util +!BUSYBOX_CONFIG_MKTEMP:coreutils-mktemp
endef

define Package/ddns-scripts-transip/description
  Dynamic DNS Client scripts extension for 'transip.nl'.
  Note: You must also install ca-certificate or ca-bundle.
  It requires:
  'option username' to be a valid username for transip.nl
  'option password' to be a valid matching private key
  'option domain' to contain the base domain
  'option param_enc' to contain the name of the DNS record to update
  'option param_opt' to contain the TTL of the DNS record to update
endef

define Package/ddns-scripts-one
	$(call Package/ddns-scripts/Default)
	TITLE:=Extension for one.com Control Panel
	DEPENDS:=ddns-scripts +curl
endef

define Package/ddns-scripts-one/description
	Dynamic DNS Client scripts extension for 'one.com'.
	It requires:
	'option username' to be a valid Email for one.com Control Panel
	'option password' to be the matching one.com Control Panel password
	'option domain' to contain the domain / subdomain
endef


define Package/ddns-scripts-porkbun
	$(call Package/ddns-scripts/Default)
	TITLE:=Extension for porkbun.com API v3
	DEPENDS:=ddns-scripts +curl
	PROVIDES:=ddns-scripts_porkbun.com-v3
endef

define Package/ddns-scripts-porkbun/description
	Dynamic DNS Client scripts extension for porkbun.com API v3 (require curl)
	It requires:
	'option username' to be a Porkbun API key
	'option password' to be the corresponding Porkbun API secret key
	'option domain' to be the FQDN for which to configure DDNS
endef

define Package/ddns-scripts-huaweicloud
  $(call Package/ddns-scripts/Default)
  TITLE:=Extension for huaweicloud.com API
  DEPENDS:=ddns-scripts +curl +openssl-util
endef

define Package/ddns-scripts-huaweicloud/description
  Dynamic DNS Client scripts extension for huaweicloud.com API (require curl and openssl)
endef

define Package/ddns-scripts-aliyun
	$(call Package/ddns-scripts/Default)
	TITLE:=Extension for Aliyun DNS API
	DEPENDS:=ddns-scripts +curl +openssl-util
endef

define Package/ddns-scripts-aliyun/description
	Dynamic DNS Client scripts extension for aliyun.com API
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

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/etc/uci-defaults/50-ddns-migrate-retry-count \
		$(1)/etc/uci-defaults/
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
	rm $(1)/usr/share/ddns/default/luadns.com-v1.json
	rm $(1)/usr/share/ddns/default/cloudflare.com-v4.json
	rm $(1)/usr/share/ddns/default/cloud.google.com-v1.json
	rm $(1)/usr/share/ddns/default/freedns.42.pl.json
	rm $(1)/usr/share/ddns/default/godaddy.com-v1.json
	rm $(1)/usr/share/ddns/default/digitalocean.com-v2.json
	rm $(1)/usr/share/ddns/default/dnspod.cn.json
	rm $(1)/usr/share/ddns/default/dnspod.cn-v3.json
	rm $(1)/usr/share/ddns/default/no-ip.com.json
	rm $(1)/usr/share/ddns/default/bind-nsupdate.json
	rm $(1)/usr/share/ddns/default/route53-v1.json
	rm $(1)/usr/share/ddns/default/cnkuai.cn.json
	rm $(1)/usr/share/ddns/default/gandi.net.json
	rm $(1)/usr/share/ddns/default/beget.com.json
	rm $(1)/usr/share/ddns/default/pdns.json
	rm $(1)/usr/share/ddns/default/scaleway.com.json
	rm $(1)/usr/share/ddns/default/transip.nl.json
	rm $(1)/usr/share/ddns/default/ns1.com.json
	rm $(1)/usr/share/ddns/default/one.com.json
	rm $(1)/usr/share/ddns/default/porkbun.com-v3.json
	rm $(1)/usr/share/ddns/default/huaweicloud.com.json
	rm $(1)/usr/share/ddns/default/aliyun.com.json
endef


define Package/ddns-scripts-utils/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./samples/slaac_sample.sh \
		$(1)/usr/lib/ddns/slaac.sh
	$(INSTALL_BIN) ./samples/getlocalip_sample.sh \
		$(1)/usr/lib/ddns/getlocalip.sh
endef


define Package/ddns-scripts-luadns/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_luadns_v1.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/luadns.com-v1.json \
		$(1)/usr/share/ddns/default/
endef

define Package/ddns-scripts-luadns/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
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


define Package/ddns-scripts-gcp/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_gcp_v1.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/cloud.google.com-v1.json \
		$(1)/usr/share/ddns/default/
endef

define Package/ddns-scripts-gcp/prerm
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

define Package/ddns-scripts-dnspod/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_dnspod_cn.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/dnspod.cn.json \
		$(1)/usr/share/ddns/default/
endef

define Package/ddns-scripts-dnspod/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-dnspod-v3/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_dnspod_cn_v3.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/dnspod.cn-v3.json \
		$(1)/usr/share/ddns/default/
endef

define Package/ddns-scripts-dnspod-v3/prerm
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


define Package/ddns-scripts-ns1/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_ns1_com.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/ns1.com.json \
		$(1)/usr/share/ddns/default
endef

define Package/ddns-scripts-ns1/prerm
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


define Package/ddns-scripts-beget/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_beget_com.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/beget.com.json \
		$(1)/usr/share/ddns/default
endef

define Package/ddns-scripts-beget/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-pdns/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_pdns.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/pdns.json \
		$(1)/usr/share/ddns/default
endef

define Package/ddns-scripts-pdns/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-scaleway/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_scaleway_com.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/scaleway.com.json \
		$(1)/usr/share/ddns/default
endef

define Package/ddns-scripts-scaleway/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-transip/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_transip_nl.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/transip.nl.json \
		$(1)/usr/share/ddns/default
endef

define Package/ddns-scripts-transip/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-one/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_one_com.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/one.com.json \
		$(1)/usr/share/ddns/default
endef

define Package/ddns-scripts-one/prerm
#!/bin/sh
if [-z "${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-porkbun/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_porkbun_v3.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/porkbun.com-v3.json \
		$(1)/usr/share/ddns/default/
endef

define Package/ddns-scripts-porkbun/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


define Package/ddns-scripts-huaweicloud/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_huaweicloud_com.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/huaweicloud.com.json \
		$(1)/usr/share/ddns/default/
endef

define Package/ddns-scripts-huaweicloud/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef

define Package/ddns-scripts-aliyun/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/usr/lib/ddns/update_aliyun_com.sh \
		$(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./files/usr/share/ddns/default/aliyun.com.json \
		$(1)/usr/share/ddns/default/
endef

define Package/ddns-scripts-aliyun/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi
exit 0
endef


$(eval $(call BuildPackage,ddns-scripts))
$(eval $(call BuildPackage,ddns-scripts-services))
$(eval $(call BuildPackage,ddns-scripts-utils))
$(eval $(call BuildPackage,ddns-scripts-luadns))
$(eval $(call BuildPackage,ddns-scripts-cloudflare))
$(eval $(call BuildPackage,ddns-scripts-gcp))
$(eval $(call BuildPackage,ddns-scripts-freedns))
$(eval $(call BuildPackage,ddns-scripts-godaddy))
$(eval $(call BuildPackage,ddns-scripts-digitalocean))
$(eval $(call BuildPackage,ddns-scripts-dnspod))
$(eval $(call BuildPackage,ddns-scripts-dnspod-v3))
$(eval $(call BuildPackage,ddns-scripts-noip))
$(eval $(call BuildPackage,ddns-scripts-nsupdate))
$(eval $(call BuildPackage,ddns-scripts-route53))
$(eval $(call BuildPackage,ddns-scripts-cnkuai))
$(eval $(call BuildPackage,ddns-scripts-gandi))
$(eval $(call BuildPackage,ddns-scripts-beget))
$(eval $(call BuildPackage,ddns-scripts-pdns))
$(eval $(call BuildPackage,ddns-scripts-scaleway))
$(eval $(call BuildPackage,ddns-scripts-transip))
$(eval $(call BuildPackage,ddns-scripts-ns1))
$(eval $(call BuildPackage,ddns-scripts-one))
$(eval $(call BuildPackage,ddns-scripts-porkbun))
$(eval $(call BuildPackage,ddns-scripts-huaweicloud))
$(eval $(call BuildPackage,ddns-scripts-aliyun))
