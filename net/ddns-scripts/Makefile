include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-scripts
# Version == major.minor.patch
# increase on new functionality (minor) or patches (patch)
PKG_VERSION:=2.3.0
# Release == build
# increase on changes of services files or tld_names.dat
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Christian Schoenebeck <christian.schoenebeck@gmail.com>
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)/Default
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=IP Addresses and Names
    PKGARCH:=all
endef

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

define Package/$(PKG_NAME)_CloudFlare
    $(call Package/$(PKG_NAME)/Default)
    TITLE:=DDNS extension for CloudFlare
    DEPENDS:=$(PKG_NAME)
endef
define Package/$(PKG_NAME)_CloudFlare/description
    Dynamic DNS Client scripts extension for CloudFlare
endef

define Package/$(PKG_NAME)_No-IP_com
    $(call Package/$(PKG_NAME)/Default)
    TITLE:=DDNS extension for No-IP.com
    DEPENDS:=$(PKG_NAME)
endef
define Package/$(PKG_NAME)_No-IP_com/description
    Dynamic DNS Client scripts extension for No-IP.com
endef

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
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/ddns
endef

define Package/$(PKG_NAME)/install
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
define Package/$(PKG_NAME)_CloudFlare/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN)  $(PKG_BUILD_DIR)/files/update_CloudFlare.sh $(1)/usr/lib/ddns
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/tld_names.dat $(1)/usr/lib/ddns
endef
define Package/$(PKG_NAME)_No-IP_com/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN)  $(PKG_BUILD_DIR)/files/update_No-IP.com.sh $(1)/usr/lib/ddns
endef

define Package/$(PKG_NAME)/postinst
	#!/bin/sh
	# if run within buildroot exit
	[ -n "$${IPKG_INSTROOT}" ] && exit 0

	# add new section "ddns" "global" if not exists
	uci -q get ddns.global > /dev/null || uci -q set ddns.global='ddns'
	uci -q get ddns.global.date_format > /dev/null || uci -q set ddns.global.date_format='%F %R'
	uci -q get ddns.global.log_lines > /dev/null || uci -q set ddns.global.log_lines='250'
	uci -q get ddns.global.allow_local_ip > /dev/null || uci -q set ddns.global.allow_local_ip='0'
	uci -q commit ddns

	# clear LuCI indexcache
	rm -f /tmp/luci-indexcache >/dev/null 2>&1

	exit 0
endef
define Package/$(PKG_NAME)_CloudFlare/postinst
	#!/bin/sh
	echo -e '"CloudFlare"\t"update_CloudFlare.sh"' >> $${IPKG_INSTROOT}/usr/lib/ddns/services
	echo -e '"CloudFlare"\t"update_CloudFlare.sh"' >> $${IPKG_INSTROOT}/usr/lib/ddns/services_ipv6
endef
define Package/$(PKG_NAME)_No-IP_com/postinst
	#!/bin/sh
	echo -e '"No-IP.com"\t"update_No-IP.com.sh"' >> $${IPKG_INSTROOT}/usr/lib/ddns/services
	echo -e '"NoIP.com"\t"update_No-IP.com.sh"' >> $${IPKG_INSTROOT}/usr/lib/ddns/services
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
define Package/$(PKG_NAME)_CloudFlare/prerm
	#!/bin/sh
	/bin/sed -i '/update_CloudFlare\.sh/ d' $${IPKG_INSTROOT}/usr/lib/ddns/services
	/bin/sed -i '/update_CloudFlare\.sh/ d' $${IPKG_INSTROOT}/usr/lib/ddns/services_ipv6
endef
define Package/$(PKG_NAME)_No-IP_com/prerm
	#!/bin/sh
	/bin/sed -i '/update_No-IP\.com\.sh/ d' $${IPKG_INSTROOT}/usr/lib/ddns/services
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)_CloudFlare))
$(eval $(call BuildPackage,$(PKG_NAME)_No-IP_com))
