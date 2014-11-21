include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-scripts
PKG_VERSION:=2.1.0
PKG_RELEASE:=2
PKG_LICENSE:=GPL-2.0

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/ddns-scripts
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=IP Addresses and Names
    TITLE:=Dynamic DNS Scripts (with IPv6 support)
    PKGARCH:=all
    MAINTAINER:=Christian Schoenebeck <christian.schoenebeck@gmail.com>
endef

define Package/ddns-scripts/description
	A highly configurable set of scripts for doing dynamic dns updates.
	NEW in this version:
	- IPv6 support
	- force communication to IPv4 or IPv6 only
	- DNS server support
	- using BIND host if installed
	- DNS requests via TCP
	- Proxy server support
	- log file support
	- support to run once
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/ddns-scripts/conffiles
/etc/config/ddns
endef

define Package/ddns-scripts/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/* $(1)/etc/config

	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/* $(1)/etc/hotplug.d/iface

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/* $(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_DATA) ./files/usr/lib/ddns/service* $(1)/usr/lib/ddns
	$(INSTALL_BIN)  ./files/usr/lib/ddns/*.sh $(1)/usr/lib/ddns
endef

define Package/ddns-scripts/postinst
	#!/bin/sh
	# if run within buildroot exit
	[ -n "$${IPKG_INSTROOT}" ] && exit 0

	# remove old sed script file
	[ -f /usr/lib/ddns/url_escape.sed ] && rm -f /usr/lib/ddns/url_escape.sed

	# luci updates are not in sync with ddns-script updates !!!
	# if old luci-app-ddns then errors during install because exist from differnt package
	# copy dynamic_dns_helper.tmp.sh -> dynamic_dns_helper.sh
	cp -f /usr/lib/ddns/dynamic_dns_lucihelper.tmp.sh /usr/lib/ddns/dynamic_dns_lucihelper.sh

	# add new section "ddns" "global" if not exists
	uci -q get ddns.global > /dev/null || uci -q set ddns.global='ddns'
	uci -q get ddns.global.date_format > /dev/null || uci -q set ddns.global.date_format='%F %R'
	uci -q get ddns.global.log_lines > /dev/null || uci -q set ddns.global.log_lines='250'
	uci -q commit ddns

	# clear LuCI indexcache
	rm -f /tmp/luci-indexcache >/dev/null 2>&1

	exit 0
endef

define Package/ddns-scripts/prerm
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

$(eval $(call BuildPackage,ddns-scripts))
