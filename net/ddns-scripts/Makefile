include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-scripts
# Version == major.minor.patch
# increase on new functionality (minor) or patches (patch)
PKG_VERSION:=2.2.0
# Release == build
# increase on changes of services files or tld_names.dat
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Christian Schoenebeck <christian.schoenebeck@gmail.com>

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=IP Addresses and Names
    TITLE:=Dynamic DNS Client scripts (with IPv6 support)
    URL:=http://wiki.openwrt.org/doc/howto/ddns.client
    DEPENDS:=
    PKGARCH:=all
    MENU:=1
endef

# shown in LuCI package description
define Package/$(PKG_NAME)/description
    $(TITLE) - Info: http://wiki.openwrt.org/doc/howto/ddns.client
endef

define Package/$(PKG_NAME)/config
	# shown in menuconfig <Help>
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
		Info   : $(URL)

		$(PKG_MAINTAINER)

	source "$(SOURCE)/Config.in"
endef

define Build/Prepare
	$(CP) ./files/* $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	if [ "$(CONFIG_DDNS-SCRIPTS_small)" = "y" ]; then \
		rm -f $(PKG_BUILD_DIR)/etc/config/ddns.sample; \
		rm -f $(PKG_BUILD_DIR)/usr/lib/ddns/update_sample.sh; \
		rm -f $(PKG_BUILD_DIR)/usr/lib/ddns/getlocalip_sample.sh; \
		DIRS="usr etc/hotplug.d etc/init.d"; \
		for DIR in $$$$DIRS; do \
			for FILE in `find $(PKG_BUILD_DIR)/$$$$DIR -type f`; do \
				$(SED) '/^\s*$$$$/ d' $$$$FILE; \
				$(SED) '/^\/\/\s/ d' $$$$FILE; \
				$(SED) 's/^\s*#/#/' $$$$FILE; \
				$(SED) '/^#\s/ d' $$$$FILE; \
				$(SED) '/^#*$$$$/ d' $$$$FILE; \
				$(SED) 's/\s#\s.*$$$$//' $$$$FILE; \
				$(SED) 's/\s*$$$$//' $$$$FILE; \
			done; \
		done; \
	fi

	[ "$(CONFIG_DDNS-SCRIPTS_sample-config)" = "y" ] || \
		rm -f $(PKG_BUILD_DIR)/etc/config/ddns.sample

	[ "$(CONFIG_DDNS-SCRIPTS_sample-update)" = "y" ] || \
		rm -f $(PKG_BUILD_DIR)/usr/lib/ddns/update_sample.sh

	[ "$(CONFIG_DDNS-SCRIPTS_sample-getlocalip)" = "y" ] || \
		rm -f $(PKG_BUILD_DIR)/usr/lib/ddns/getlocalip_sample.sh

	[ "$(CONFIG_DDNS-SCRIPTS_provider-cloudflare-com)" = "y" ] || { \
		rm -f $(PKG_BUILD_DIR)/usr/lib/ddns/update_cloudflare.sh; \
		rm -f $(PKG_BUILD_DIR)/usr/lib/ddns/tld_names.dat; \
		$(SED) '/update_cloudflare\.sh/ d' $(PKG_BUILD_DIR)/usr/lib/ddns/services; \
		$(SED) '/update_cloudflare\.sh/ d' $(PKG_BUILD_DIR)/usr/lib/ddns/services_ipv6; \
	}
	[ "$(CONFIG_DDNS-SCRIPTS_provider-noip-com)" = "y" ] || { \
		rm -f $(PKG_BUILD_DIR)/usr/lib/ddns/update_no-ip.sh; \
		$(SED) '/update_no-ip\.sh/ d' $(PKG_BUILD_DIR)/usr/lib/ddns/services; \
		$(SED) '/update_no-ip\.sh/ d' $(PKG_BUILD_DIR)/usr/lib/ddns/services_ipv6; \
	}
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/ddns
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/etc/config/* $(1)/etc/config

	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/etc/hotplug.d/iface/* $(1)/etc/hotplug.d/iface

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/etc/init.d/* $(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/usr/lib/ddns/* $(1)/usr/lib/ddns
	$(INSTALL_BIN)  $(PKG_BUILD_DIR)/usr/lib/ddns/*.sh $(1)/usr/lib/ddns
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

$(eval $(call BuildPackage,$(PKG_NAME)))
