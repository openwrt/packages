#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-scripts
# Version == major.minor.patch
# increase on new functionality (minor) or patches (patch)
PKG_VERSION:=2.7.5
# Release == build
# increase on changes of services files or tld_names.dat
PKG_RELEASE:=3

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Christian Schoenebeck <christian.schoenebeck@gmail.com>

include $(INCLUDE_DIR)/package.mk

# no default dependencies
PKG_DEFAULT_DEPENDS=

define Package/$(PKG_NAME)/Default
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=IP Addresses and Names
    PKGARCH:=all
endef

##### **********************************
define Package/$(PKG_NAME)
    $(call Package/$(PKG_NAME)/Default)
    TITLE:=Dynamic DNS Client scripts (with IPv6 support)
endef
# shown in LuCI package description
define Package/$(PKG_NAME)/description
    Dynamic DNS Client scripts (with IPv6 support) - Info: http://wiki.openwrt.org/doc/howto/ddns.client
endef
# shown in menuconfig <Help>
define Package/$(PKG_NAME)/config
	help
		A highly configurable set of scripts for doing dynamic dns updates.
		  - IPv6 support
		  - force communication to IPv4 or IPv6 only
		  - DNS server support
		  - using BIND host if installed
		  - DNS requests via TCP
		  - Proxy server support
		  - log file support
		  - support to run once
		Version: $(PKG_VERSION)-$(PKG_RELEASE)
		Info   : http://wiki.openwrt.org/doc/howto/ddns.client
		$(PKG_MAINTAINER)
endef

##### **********************************
define Package/$(PKG_NAME)_cloudflare
    $(call Package/$(PKG_NAME)/Default)
    TITLE:=DDNS extension for CloudFlare.com
    DEPENDS:=$(PKG_NAME)
endef
define Package/$(PKG_NAME)_cloudflare/description
    Dynamic DNS Client scripts extension for CloudFlare.com
endef

##### **********************************
define Package/$(PKG_NAME)_no-ip_com
    $(call Package/$(PKG_NAME)/Default)
    TITLE:=DDNS extension for No-IP.com
    DEPENDS:=$(PKG_NAME)
endef
define Package/$(PKG_NAME)_no-ip_com/description
    Dynamic DNS Client scripts extension for No-IP.com
endef

##### **********************************
define Package/$(PKG_NAME)_nsupdate
    $(call Package/$(PKG_NAME)/Default)
    TITLE:=DDNS extension using Bind nsupdate
    DEPENDS:=$(PKG_NAME) +bind-client
endef
define Package/$(PKG_NAME)_nsupdate/description
    Dynamic DNS Client scripts extension for direct updates using Bind nsupdate
endef
define Package/$(PKG_NAME)_nsupdate/config
    help
	The script directly updates a PowerDNS (or maybe bind server) via nsupdate
	from bind-client package. It requires
	"option dns_server" to be set to the server to be used by nsupdate.
	"option username" should be set to the key name and
	"option password" to the base64 encoded shared secret.

endef

##### **********************************
define Build/Configure
endef
define Build/Compile
	$(CP) ./files $(PKG_BUILD_DIR)
	for FILE in `find $(PKG_BUILD_DIR)/files -type f`; do \
		$(SED) 's/^\s*#/#/' \
		-e '/^#\s\|^#$$$$/d' \
		-e 's/\s#\s.*$$$$//' \
		-e 's/\s*$$$$//' \
		-e '/^\/\/\s/d'	\
		-e '/^\s*$$$$/d'	$$$$FILE; \
	done
	gzip -f9 $(PKG_BUILD_DIR)/files/tld_names.dat
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/ddns
endef

##### **********************************
define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/ddns.defaults $(1)/etc/uci-defaults/ddns
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/ddns.hotplug $(1)/etc/hotplug.d/iface/95-ddns
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/ddns.init $(1)/etc/init.d/ddns
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/files/ddns.config $(1)/etc/config/ddns

	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/services* $(1)/usr/lib/ddns
	$(INSTALL_BIN)  $(PKG_BUILD_DIR)/files/dynamic_*.sh $(1)/usr/lib/ddns
endef
define Package/$(PKG_NAME)/prerm
	#!/bin/sh
	# if run within buildroot exit
	[ -n "$${IPKG_INSTROOT}" ] && exit 0

	# stop running scripts
	/etc/init.d/ddns disable
	/etc/init.d/ddns stop

	# clear LuCI indexcache
	rm -f /tmp/luci-indexcache >/dev/null 2>&1

	exit 0
endef

##### **********************************
define Package/$(PKG_NAME)_cloudflare/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN)  $(PKG_BUILD_DIR)/files/update_cloudflare_com.sh $(1)/usr/lib/ddns
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/tld_names.dat.gz $(1)/usr/lib/ddns
endef
define Package/$(PKG_NAME)_cloudflare/postinst
	#!/bin/sh
	echo -e '"cloudflare.com"\t"update_cloudflare_com.sh"' >> $${IPKG_INSTROOT}/usr/lib/ddns/services
	echo -e '"cloudflare.com"\t"update_cloudflare_com.sh"' >> $${IPKG_INSTROOT}/usr/lib/ddns/services_ipv6
	/bin/sed -i '/service_name/s/CloudFlare/cloudflare\.com/g' $${IPKG_INSTROOT}/etc/config/ddns
endef
define Package/$(PKG_NAME)_cloudflare/prerm
	#!/bin/sh
	/bin/sed -i '/update_cloudflare_com\.sh/ d' $${IPKG_INSTROOT}/usr/lib/ddns/services
	/bin/sed -i '/update_cloudflare_com\.sh/ d' $${IPKG_INSTROOT}/usr/lib/ddns/services_ipv6
endef

##### **********************************
define Package/$(PKG_NAME)_no-ip_com/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN)  $(PKG_BUILD_DIR)/files/update_no-ip_com.sh $(1)/usr/lib/ddns
endef
define Package/$(PKG_NAME)_no-ip_com/postinst
	#!/bin/sh
	echo -e '"no-ip.com"\t"update_no-ip_com.sh"' >> $${IPKG_INSTROOT}/usr/lib/ddns/services
	/bin/sed -i '/service_name/s/NoIP\.com/no-ip\.com/g'  $${IPKG_INSTROOT}/etc/config/ddns
	/bin/sed -i '/service_name/s/No-IP\.com/no-ip\.com/g' $${IPKG_INSTROOT}/etc/config/ddns
endef
define Package/$(PKG_NAME)_no-ip_com/prerm
	#!/bin/sh
	/bin/sed -i '/update_no-ip_com\.sh/ d' $${IPKG_INSTROOT}/usr/lib/ddns/services
endef

##### **********************************
define Package/$(PKG_NAME)_nsupdate/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN)  $(PKG_BUILD_DIR)/files/update_nsupdate.sh $(1)/usr/lib/ddns
endef
define Package/$(PKG_NAME)_nsupdate/postinst
	#!/bin/sh
	echo -e '"bind-nsupdate"\t"update_nsupdate.sh"' >> $${IPKG_INSTROOT}/usr/lib/ddns/services
	echo -e '"bind-nsupdate"\t"update_nsupdate.sh"' >> $${IPKG_INSTROOT}/usr/lib/ddns/services_ipv6
	/bin/sed -i '/service_name/s/Bind-nsupdate/bind-nsupdate/g' $${IPKG_INSTROOT}/etc/config/ddns
endef
define Package/$(PKG_NAME)_nsupdate/prerm
	#!/bin/sh
	/bin/sed -i '/update_nsupdate\.sh/ d' $${IPKG_INSTROOT}/usr/lib/ddns/services
	/bin/sed -i '/update_nsupdate\.sh/ d' $${IPKG_INSTROOT}/usr/lib/ddns/services_ipv6
endef

##### **********************************
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)_cloudflare))
$(eval $(call BuildPackage,$(PKG_NAME)_no-ip_com))
$(eval $(call BuildPackage,$(PKG_NAME)_nsupdate))
